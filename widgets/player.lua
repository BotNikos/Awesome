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
   font = "Fira Code Bold 24",
   text = "Here need to be song title",
   forced_height = 35,
   widget = wibox.widget.textbox
}

local playerAuthor = wibox.widget {
   font = "Fira Code Bold 14",
   text = "Here need to be song author",
   widget = wibox.widget.textbox
}

-- TODO:
-- Объеденить прогрессбар и время в один виджет
-- который позволит настроить процентноее соотнешение
-- размеров для каждого wibox.layout.ratio.horizontal

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

local playerTime = wibox.widget {
   font = "Fira Code Bold 14",
   text = "0:00/0:00",
   forced_width = 100,
   widget = wibox.widget.textbox
}

local player = wibox.widget {
   {
      {
         playerIcon,
         {
            playerTitle,
            playerAuthor,

            {
                playerProgress,
                playerTime,
                layout = wibox.layout.align.horizontal
            },

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

local lastMetadataName = ""
function checkPlayer ()
   awful.spawn.easy_async_with_shell ('playerctl metadata --format "{{title}}|{{artist}}|{{mpris:length}}|{{mpris:artUrl}}"', function (out)
                                         if out ~= lastMetadataName then
                                            lastMetadataName = out
                                            local songInfo = gears.string.split(out, "|")
                                            awful.spawn.easy_async_with_shell ('curl -o ~/.config/awesome/tmp/playerIcon.png ' .. tostring(songInfo[4]), function ()
                                                                                  playerIcon.image = gears.surface.load_uncached ("/home/bot_nikos/.config/awesome/tmp/playerIcon.png")
                                                                                  playerTitle.text = songInfo[1]
                                                                                  playerAuthor.text = songInfo[2]
                                                                                  playerProgress.maximum = tonumber(songInfo[3])

                                            end)
                                         end
   end)
end

local testTimer = gears.timer {timeout = 1}
testTimer:connect_signal('timeout', checkPlayer)
testTimer:start()

return player
