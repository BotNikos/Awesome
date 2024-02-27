local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")


local colors = require "colors"

local currentState = 'right'

local commands = {
   mirror = "xrandr --output HDMI-2 --same-as HDMI-0",
   right = "xrandr --output HDMI-2 --right-of HDMI-0 --auto"
}

local togglerText = wibox.widget {
   font = "Mononoki Nerd Font 15",
   text = currentState == "right" and "mirror" or "right",
   halign = "center",
   valign = "center",
   widget = wibox.widget.textbox
}

function toggle () 
   currentState = currentState == "right" and "mirror" or "right"
   togglerText.text = currentState == "right" and "mirror" or "right"
   awful.spawn (commands[currentState])
end

local monitorToggler = wibox.widget {
   {

      {
         {
            {
               image = os.getenv("HOME") .. "/.config/awesome/icons/feather_48px/monitor.svg",
               forced_width = 30,
               forced_height = 30,
               halign = "center",
               valing = "center",
               widget = wibox.widget.imagebox
            },

            {
               togglerText,
               margins = 10,
               widget = wibox.container.margin
            },

            widget = wibox.layout.fixed.vertical
         },
         margins = 10,
         widget = wibox.container.margin
      },

      buttons = {
         awful.button ({}, 1, nil, toggle)
      },
      
      bg = colors.background2,
      widget = wibox.container.background
   },
   top = 10,
   right = 10,
   widget = wibox.container.margin
}

monitorToggler.widget:connect_signal("mouse::enter", function () monitorToggler.widget.bg = colors.violet end)
monitorToggler.widget:connect_signal("mouse::leave", function () monitorToggler.widget.bg = colors.background2 end)

return monitorToggler

