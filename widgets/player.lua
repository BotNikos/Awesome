local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")

local colors = require "colors"

local playerIcon = wibox.widget {
      resize = true,
      forced_width = 150,
      forced_height = 150,
      widget = wibox.widget.imagebox
}

local playerTitle = wibox.widget {
   font = "Mononoki Nerd Font Bold 24",
   text = "Here need to be song title",
   forced_height = 40,
   widget = wibox.widget.textbox
}

local playerAuthor = wibox.widget {
   font = "Mononoki Nerd Font 14",
   text = "Here need to be song author",
   widget = wibox.widget.textbox
}

local playerProgress = wibox.widget {
   value = 25,
   max_value = 100,
   color = colors.violet,
   background_color = colors.foreground,
   forced_height = 35,
   margins = {
      top = 15,
      bottom = 15
   },

   widget = wibox.widget.progressbar,
   
}

-- TODO: Add fuction to seek track

local playerTime = wibox.widget {
   font = "Mononoki Nerd Font 14",
   text = "0:00/0:00",
   widget = wibox.widget.textbox
}

local progressContainer = wibox.widget {
   {
      playerProgress,
      right = 10,
      widget = wibox.container.margin
   },
   playerTime,
   forced_width = 430,
   layout = wibox.layout.ratio.horizontal
}
progressContainer:set_ratio(1, 0.75)
progressContainer:set_ratio(2, 0.25)

local buttonSize = 40
local skipBackViolet = '<svg width="45" height="45" viewBox="0 0 24 24" fill="none" stroke="' .. colors.violet .. '" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-skip-back "><polygon points="19 20 9 12 19 4 19 20"></polygon><line x1="5" y1="19" x2="5" y2="5"></line></svg>'
local pauseViolet = '<svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="' .. colors.violet .. '" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-pause"><rect x="6" y="4" width="4" height="16"></rect><rect x="14" y="4" width="4" height="16"></rect></svg>'
local skipNextVoliet = '<svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="' .. colors.violet .. '" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-skip-forward"><polygon points="5 4 15 12 5 20 5 4"></polygon><line x1="19" y1="5" x2="19" y2="19"></line></svg>' 

local buttonPrevious = wibox.widget {
   image = os.getenv ("HOME") .. "/.config/awesome/icons/feather_48px/skip-back.svg",
   forced_width = buttonSize,
   forced_height = buttonSize,
   halign = 'center',
   buttons = {
      awful.button ({}, 1, nil, function () awful.spawn ("playerctl previous") end)
   },
   widget = wibox.widget.imagebox 
}

buttonPrevious:connect_signal("mouse::enter", function () buttonPrevious.image = skipBackViolet end)
buttonPrevious:connect_signal("mouse::leave", function () buttonPrevious.image = os.getenv ("HOME") .. "/.config/awesome/icons/feather_48px/skip-back.svg" end)

local buttonTogglePause = wibox.widget {
   image = os.getenv ("HOME") .. "/.config/awesome/icons/feather_48px/pause.svg",
   forced_width = buttonSize,
   forced_height = buttonSize,
   halign = 'center',
   buttons = {
      awful.button ({}, 1, nil, function () awful.spawn ("playerctl play-pause") end)
   },
   widget = wibox.widget.imagebox 
}

buttonTogglePause:connect_signal("mouse::enter", function () buttonTogglePause.image = pauseViolet end)
buttonTogglePause:connect_signal("mouse::leave", function () buttonTogglePause.image = os.getenv ("HOME") .. "/.config/awesome/icons/feather_48px/pause.svg" end)

local buttonNext = wibox.widget {
   image = os.getenv ("HOME") .. "/.config/awesome/icons/feather_48px/skip-forward.svg",
   forced_width = buttonSize,
   forced_height = buttonSize,
   halign = 'center',
   buttons = {
      awful.button ({}, 1, nil, function () awful.spawn ("playerctl next") end)
   },
   widget = wibox.widget.imagebox 
}

buttonNext:connect_signal("mouse::enter", function () buttonNext.image = skipNextVoliet end)
buttonNext:connect_signal("mouse::leave", function () buttonNext.image = os.getenv ("HOME") .. "/.config/awesome/icons/feather_48px/skip-forward.svg" end)

local buttonsContainer = wibox.widget {
   buttonPrevious,
   buttonTogglePause,
   buttonNext,
   layout = wibox.layout.flex.horizontal
}

local player = wibox.widget {
   {
      {
         playerIcon,
         {
            playerTitle,
            playerAuthor,
            progressContainer,
            buttonsContainer,
            layout = wibox.layout.fixed.vertical
         },
         spacing = 15,
         layout = wibox.layout.fixed.horizontal
      },

      margins = 10,
      widget = wibox.container.margin
   },

   bg = colors.background2,
   forced_width = 600,
   widget = wibox.container.background
}

function timeToSec (time)
   local timeSplited = gears.string.split(time, ":")
   return tonumber(timeSplited[1]) * 60 + tonumber(timeSplited[2]) -- 60 seconds in minute
end

local lastMetadata = ""
function changePlayer (out)

   local songInfo = gears.string.split(out, "|")

   if out ~= lastMetadata then
      lastMetadata = out
      awful.spawn.easy_async_with_shell ('curl -o ~/.config/awesome/tmp/playerIcon.png ' .. tostring(songInfo[4]), function ()
                                            local songLengthSeconds = timeToSec (songInfo[3])

                                            playerIcon.image = gears.surface.load_uncached (os.getenv ("HOME") .. "/.config/awesome/tmp/playerIcon.png")
                                            playerTitle.text = songInfo[1]
                                            playerAuthor.text = songInfo[2]
                                            playerProgress.max_value = songLengthSeconds
                                            playerTime.text = "0:00/" .. songInfo[3]
                                            playerProgress.value = 0
      end)
   else
      awful.spawn.easy_async_with_shell ('playerctl position --format "{{duration(position)}}|"', function (out)
                                            local songTime = gears.string.split (out, "|")
                                            local songTimeSeconds = timeToSec (songTime[1])

                                            playerTime.text = songTime[1] .. "/" .. songInfo[3]
                                            playerProgress.value = songTimeSeconds
      end)
   end
end

function checkPlayer ()
   awful.spawn.easy_async_with_shell ("playerctl status", function (out)
                                         local playerStatus = gears.string.split(out, "\n")
                                         if playerStatus[1] ~= "Stopped" and playerStatus[1] ~= "" then
                                            awful.spawn.easy_async_with_shell ('playerctl metadata --format "{{title}}|{{artist}}|{{duration(mpris:length)}}|{{mpris:artUrl}}"', changePlayer)
                                         end
   end)
end

local playerCheckTimer = gears.timer {timeout = 1}
playerCheckTimer:connect_signal('timeout', checkPlayer)
playerCheckTimer:start()

return player
