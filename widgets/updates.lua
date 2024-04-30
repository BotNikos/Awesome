local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")

local colors = require "colors"

local updatesCount = wibox.widget {
   font = "Mononoki Nerd Font Bold 24",
   text = "Collectin info",

   forced_width = 600 - 20 - 30 - 10, -- 600 - sidebar width, 20 - this widget margins, 30 - icon size, 10 - right icon margin (×_×)
   halign = "center",
   widget = wibox.widget.textbox
}

local checkTimer = gears.timer {
   timeout = 3600,
   autostart = true,
   call_now = true,
   callback = function ()
      awful.spawn.easy_async_with_shell ('checkupdates | wc -l', function (out)
                                            local updatesCountTrimmed = gears.string.split (out, "\n")[1]
                                            local needToUpdateVariants = {
                                               updatesCountTrimmed .. " packages needs to update",
                                               "You can update " .. updatesCountTrimmed .. " packages",
                                               updatesCountTrimmed .. " packages wants to update",
                                               "Update " .. updatesCountTrimmed .. " packages, please!",
                                               "Hey, update your " .. updatesCountTrimmed .. " packages",
                                            }

                                            local allUpdatesVariants = {
                                               "All updated",
                                               "No need to install updates",
                                            }

                                            if tonumber (updatesCountTrimmed) ~= 0 then
                                                  updatesCount.text = needToUpdateVariants[ math.random (#needToUpdateVariants) ]
                                            else
                                                  updatesCount.text = allUpdatesVariants[ math.random (#allUpdatesVariants) ]
                                            end
      end)
   end
}

local updates = wibox.widget {
   {
      {
         {
            {
               image = os.getenv ("HOME") .. "/.config/awesome/icons/feather_100px/arrow-down-circle.svg",
               forced_width = 30,
               forced_height = 30,
               halign = "center",
               valign = "center",
               widget = wibox.widget.imagebox,
            },

            right = 10,
            widget = wibox.container.margin
         },

         updatesCount,

         layout = wibox.layout.fixed.horizontal
      },

      margins = 10,
      widget = wibox.container.margin
   },

   buttons = {
      awful.button ({}, 1, nil, function () awful.spawn.easy_async_with_shell (terminal .. ' sudo pacman -Suy ', function () checkTimer:emit_signal ('timeout') end) end)
   },

   bg = colors.background2,
   widget = wibox.container.background
}

updates:connect_signal ("mouse::enter", function () updates.bg = colors.violet end)
updates:connect_signal ("mouse::leave", function () updates.bg = colors.background2 end)


return updates
