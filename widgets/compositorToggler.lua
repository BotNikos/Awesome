local awful = require("awful")
local wibox = require("wibox")

local colors = require "colors"

local compStatus = "enabled" 
local commands = {}
commands.enabled = "killall compfy"
commands.disabled = "compfy --daemon"

local hint = wibox.widget {
   font = "Mononoki Nerd Font 15",
   text = compStatus,
   halign = "center",
   widget = wibox.widget.textbox,
}

local compositorToggler = wibox.widget {
   {
      {
         {
            image = os.getenv ("HOME") .. "/.config/awesome/icons/feather_100px/zap.svg",
            forced_width = 30,
            forced_height = 30,
            halign = "center",
            widget = wibox.widget.imagebox
         },

         {
            hint,
            top = 10,
            widget = wibox.container.margin
         },

         layout = wibox.layout.fixed.vertical
      },

      margins = 10,
      widget = wibox.container.margin

   },

   buttons = {
      awful.button ({}, 1, nil, function ()
            awful.spawn (commands[compStatus])
            compStatus = compStatus == "enabled" and "disabled" or "enabled"
            hint.text = compStatus
      end) 
   },

   bg = colors.background2,
   widget = wibox.container.background
}

compositorToggler:connect_signal("mouse::enter", function () compositorToggler.bg = colors.violet end)
compositorToggler:connect_signal("mouse::leave", function () compositorToggler.bg = colors.background2 end)

return compositorToggler
