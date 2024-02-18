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

local buttonPrevious = wibox.widget {
   {
      image = os.getenv ("HOME") .. "/.config/awesome/icons/feather_48px/skip-back.svg",
      halign = 'center',
      buttons = {
         awful.button ({}, 1, nil, function () awful.spawn ("playerctl previous") end)
      },
      widget = wibox.widget.imagebox 
   },
   widget = wibox.container.background
}

buttonPrevious:connect_signal("mouse::enter", function () buttonPrevious.bg = colors.violet end)
buttonPrevious:connect_signal("mouse::leave", function () buttonPrevious.bg = colors.background2 end)

-- TODO: Toggle icon after click
local buttonTogglePause = wibox.widget {
   {
      image = os.getenv ("HOME") .. "/.config/awesome/icons/feather_48px/pause.svg",
      forced_width = buttonSize,
      forced_height = buttonSize,
      halign = 'center',
      buttons = {
         awful.button ({}, 1, nil, function () awful.spawn ("playerctl play-pause") end)
      },
      widget = wibox.widget.imagebox 
   },
   widget = wibox.container.background
}

buttonTogglePause:connect_signal("mouse::enter", function () buttonTogglePause.bg = colors.violet end)
buttonTogglePause:connect_signal("mouse::leave", function () buttonTogglePause.bg = colors.background2 end)

local buttonNext = wibox.widget {
   {
      image = os.getenv ("HOME") .. "/.config/awesome/icons/feather_48px/skip-forward.svg",
      forced_width = buttonSize,
      forced_height = buttonSize,
      halign = 'center',
      buttons = {
         awful.button ({}, 1, nil, function () awful.spawn ("playerctl next") end)
      },
      widget = wibox.widget.imagebox 
   },
   widget = wibox.container.background
}

buttonNext:connect_signal("mouse::enter", function () buttonNext.bg = colors.violet end)
buttonNext:connect_signal("mouse::leave", function () buttonNext.bg = colors.background2 end)

local buttonSize = 50
local buttonsContainer = wibox.widget {
   buttonPrevious,
   buttonTogglePause,
   buttonNext,
   forced_height = buttonSize,
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
