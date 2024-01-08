local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

-- colors
background = "#282A36"
background2 = "#383A59"
foreground = "#F4F4EF"
violet = "#BD93F9"
orange = "#FF9C32"
majenta = "#FF79C6"
blue = "#7CCCDF"

systemInfo = awful.popup {
   widget = {
      {
         {
            text = "Some test",
            widget = wibox.widget.textbox
         },
         layout = wibox.layout.fixed.vertical
      },
      margins = 10,
      widget = wibox.container.margin
   },
   border_width = 2,
   screen = screen[1],
   placement = awful.placement.right,

   visible = false,
   ontop = true,
   border_color = violet,
}

langLay = awful.popup {
   widget = {
      {
         font = "Fira Code Bold 50",
         widget = wibox.widget.textbox
      },
      top = 10,
      bottom = 10,
      right = 30,
      left = 30,
      widget = wibox.container.margin 
   },

   hide_on_right_click = true,
   border_width = 2,
   screen = screen[1],
   placement = awful.placement.centered,
   visible = false,
   ontop = true,
   border_color = violet
}

return {
   systemInfo = systemInfo,
   langLay = langLay,
} 
