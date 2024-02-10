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
   forced_height = 35,
   widget = wibox.widget.textbox
}

local playerAuthor = wibox.widget {
   font = "Mononoki Nerd Font 14",
   text = "Here need to be song author",
   widget = wibox.widget.textbox
}

-- TODO: Change slider widget to progressbar widget
-- make seeking on button::release signal
-- progressbar:connect_signal("button::release", fuction () ... end)

local playerProgress = wibox.widget {
   value = 25,
   minimum = 0,
   maximum = 100,
   handle_shape = gears.shape.circle,
   handle_color = colors.violet,
   bar_shape = gears.shape.rect,
   bar_active_color = colors.violet,
   bar_color = colors.foreground,
   bar_height = 3,
   forced_height = 35,
   widget = wibox.widget.slider
}

local currentTime = 0
playerProgress:connect_signal("property::value", function (_, newTime)
                                 if newTime ~= currentTime then
                                    awful.spawn.easy_async_with_shell ("playerctl position " .. tostring (newTime), function () end)
                                 end
end)

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

local player = wibox.widget {
   {
      {
         playerIcon,
         {
            playerTitle,
            playerAuthor,
            progressContainer,
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
                                            playerProgress.maximum = songLengthSeconds
                                            playerTime.text = "0:00/" .. songInfo[3]
                                            playerProgress.value = 0
                                            currentTime = 0
      end)
   else
      awful.spawn.easy_async_with_shell ('playerctl position --format "{{duration(position)}}|"', function (out)
                                            local songTime = gears.string.split (out, "|")
                                            local songTimeSeconds = timeToSec (songTime[1])

                                            playerTime.text = songTime[1] .. "/" .. songInfo[3]
                                            currentTime = songTimeSeconds
                                            playerProgress.value = songTimeSeconds
      end)
   end
end

function checkPlayer ()

   awful.spawn.easy_async_with_shell ("playerctl status", function (out)
                                         if out ~= "" then
                                            awful.spawn.easy_async_with_shell ('playerctl metadata --format "{{title}}|{{artist}}|{{duration(mpris:length)}}|{{mpris:artUrl}}"', changePlayer)
                                         end
   end)
end

local playerCheckTimer = gears.timer {timeout = 1}
playerCheckTimer:connect_signal('timeout', checkPlayer)
playerCheckTimer:start()

return player
