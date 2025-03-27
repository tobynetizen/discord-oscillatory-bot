local discordia = require('discordia')
local client = discordia.Client()

function string:split(delim)
  local result = {}
  local pattern = "(.-)" .. delim
  local lastPos = 1
  local startPos, endPos, match

  while true do
    startPos, endPos, match = self:find(pattern, lastPos)
    if not startPos then
      break
    end
    table.insert(result, match)
    lastPos = endPos + 1
  end

  local lastPart = self:sub(lastPos)
  if lastPart ~= "" then
    table.insert(result, lastPart)
  end

  return result
end

function string:startswith(prefix)
  return self:sub(1, #prefix) == prefix
end

local tokenFile = io.open('./token.txt')
local token = tokenFile:read('*a')
tokenFile:close()

local prefix = '/'

local function sendRulesEmbed(channel)
    local executiveDirectorRoleId = "0"
    local communityManagerRoleId = "0"

    local rules = {
      "1. Be respectful to other server members",
      "2. Controversial topics such as politics and religion are prohibited",
      "3. This is an English speaking server, please do not use any other languages",
      "4. No advertisements or self-promotion of any kind",
      "5. Do not share personally identifiable information unless in a private DM, private channel, or private thread",
      "6. No illegal or explicit material allowed in any channels",
      "7. No excessive spamming, some spamming will be allowed under certain conditions, this will be decided by the @Community Manager",
      "8. The @Executive Director and @Community Manager are the only persons who have the authority to take action against infractions or infringements upon the rules stated above"
    }

    local description = table.concat(rules, "\n")
    description = description:gsub("(@Community Manager)", "<@&" .. communityManagerRoleId .. ">")
    description = description:gsub("(@Executive Director)", "<@&" .. executiveDirectorRoleId .. ">")

    local embed = {
      title = "Rules",
      description = description,
      color = 0xA9A9A9,
      footer = {
        text = "If you have any questions regarding the rules, contact a Community Manager."
      }
    }

    channel:send { embed = embed }
end

local function sendWelcomeEmbed(channel)
    local rulesChannelId = "0"
    local newsChannelId = "0"
    local chatChannelId = "0"

    local welcome = {
        "#rules - Please follow the rules of the server",
        "#chat - Communicate with other server members",
        "#news - Check out news about the server or upcoming games",
    }

    local description = table.concat(welcome, "\n")
    description = description:gsub("(#rules)", "<#" .. rulesChannelId .. ">")
    description = description:gsub("(#news)", "<#" .. newsChannelId .. ">")
    description = description:gsub("(#chat)", "<#" .. chatChannelId .. ">")

    local embed = {
        title = "Welcome to the community server!",
        description = description,
        color = 0xA9A9A9,
        footer = {
          text = ""
        }
    }
      
    channel:send { embed = embed }
end

local function sendNewsEmbed(channel)
    local newsChannelId = "0"
    local welcome = {
        "https://www.roblox.com/"
    }

    local description = table.concat(welcome, "\n")

    local embed = {
        title = "We now have a Roblox group!",
        description = description,
        color = 0xA9A9A9,
        footer = {
          text = ""
        }
    }
      
    channel:send { embed = embed }
end

local function sendCodeEmbed(channel, codePath)
    local file = io.open(codePath, 'r')
    if not file then
      channel:send('Error: Could not read the Lua code file.')
      return
    end
    local code = file:read('*all')
    file:close()
  
    local embed = {
      title = "",
      description = "",
      color = 0x1E90FF,
      fields = {
        {
          name = "",
          value = "```lua\n" .. code .. "\n```"
        }
      },
      footer = {
        text = ""
      }
    }
  
    channel:send { embed = embed }
end

local function sendInviteEmbed(channel)
    local inviteLink = "https://discord.com/"

    local embed = {
        title = "",
        description = "",
        color = 0xA9A9A9,
        fields = {
            {
                name = "Server Invite Link",
                value = inviteLink,
                inline = false
            }
        },
        footer = {
            text = ""
        }
    }

    channel:send { embed = embed }
end

local function sendInviteMessage(channel)
    channel:send("\nhttps://discord.com/")
end

local function sendFirstMessage(channel)
    channel:send("\nfirst")
end

client:on('messageCreate', function(message)
  local args = message.content:split(' ')
  local command

  pcall(function()
    command = args[1]:lower()
  end)

  if not message.content:startswith(prefix) then
    return
  end

  command = command:sub(#prefix + 1)

  if command == 'clear' then
    local numMessages = tonumber(args[2])
    if not numMessages or numMessages < 1 then
      message:reply('Please specify a valid number of messages to delete.')
      return
    end

    message.channel:getMessages(numMessages):forEach(function(msg)
      msg:delete()
    end)
  elseif command == 'rules' then
    sendRulesEmbed(message.channel)
  elseif command == 'code' then
    local codePath = args[2]
    if not codePath then
      message:reply('Please specify the path to the Lua code file. Example: `/code /path/to/code.lua`')
      return
    end
    sendCodeEmbed(message.channel, codePath)
  elseif command == 'invite' then
    sendInviteEmbed(message.channel)
  elseif command == 'welcome' then
    sendWelcomeEmbed(message.channel)
  elseif command == 'update' then
    sendNewsEmbed(message.channel)
  elseif command == 'invite2' then
    sendInviteMessage(message.channel)
  elseif command == 'first' then
    sendFirstMessage(message.channel)
  end
end)

client:on('ready', function()
  print('Bot is ready!')
end)

client:run('Bot ' .. token)
