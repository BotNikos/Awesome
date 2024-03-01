local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")

local colors = require "colors"

local calendar = wibox.widget {
   date = os.date('*t'),
   spacing = 20,
   font = "Mononoki Nerd Font Bold 18",
   widget = wibox.widget.calendar.month
}

local popup = awful.popup {

   widget = {
      {
         widget = calendar
      },
      margins = 10,
      widget = wibox.container.margin
   },

   ontop = true,
   visible = false,

   border_width = 2,
   border_color =  colors.violet,
}

local popupCloseTimer = gears.timer {
   timeout = 1,
   single_shot = true,
   callback = function ()
      popup.visible = false
   end
}

popup:connect_signal("mouse::leave", function () popupCloseTimer:again() end)
popup:connect_signal("mouse::enter", function () popupCloseTimer:stop() end)

function toggle ()
   local currentScreen = awful.screen.focused ()
   popup.y = 60 
   popup.x = currentScreen.workarea.x + currentScreen.workarea.width - popup.width - 15
   popup.visible = not popup.visible 
end

return {
   toggle = toggle,
}
