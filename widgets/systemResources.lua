local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")

local colors = require "colors"

-- feather icons
-- CPU - cpu.svg
-- RAM - database.svg
-- drive - hard_dirve.svg

local sidebarSize = 600 -- idk how to get it from sidebar.lua ¯\_(ツ)_/¯ 

local cpu = wibox.widget {
   {
      font = "Mononoki Nerd Font Bold 20",
      text = "CPU",

      halign = "center",
      valign = "center",

      widget = wibox.widget.textbox
   },

   value = 0,
   max_value = 100,
   min_value = 0,

   color = colors.violet,
   border_color = colors.foreground,
   border_width = 10,

   widget = wibox.container.radialprogressbar
}


-- update cpu value
local cpuLoad = 0
gears.timer {
   timeout = 3,
   autostart = true,
   callback = function ()
      awful.spawn.easy_async_with_shell ('mpstat 1 1 | grep Average | awk \'{print $12}\'', function (out)
                                            local idle = gears.string.split (out, "\n")[1]
                                            cpu.value = 100 - idle
                                            -- cpu.widget.text = "CPU:\n" .. tostring (100 - idle)
      end)
   end
}

local systemResources = wibox.widget {
   {
      {
         cpu,
         margins = 10,
         widget = wibox.container.margin
      },

      bg = colors.background2,
      widget = wibox.container.background
   },

   {
      {
         cpu,
         margins = 10,
         widget = wibox.container.margin
      },

      bg = colors.background2,
      widget = wibox.container.background
   },

   {
      {
         cpu,
         margins = 10,
         widget = wibox.container.margin
      },

      bg = colors.background2,
      widget = wibox.container.background
   },

   spacing = 10,
   layout = wibox.layout.flex.horizontal
}

return wibox.widget {
   systemResources,
   bottom = 10,
   widget = wibox.container.margin
}

