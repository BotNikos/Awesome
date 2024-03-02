local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")

local keyboardlayout = 'us'
local langTimer = gears.timer {
   timeout = 2,
   single_shot = true,
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
   border_color = colors.violet,
   screen = screen[1],
   placement = awful.placement.centered,
   visible = false,
   ontop = true
}

function langChange ()
   keyboardlayout = keyboardlayout == "ru" and "us" or "ru"
   awful.spawn("setxkbmap " .. keyboardlayout)
   langLay.screen = awful.screen.focused()
   langLay.widget.widget.text = string.upper(keyboardlayout)
   langLay.visible = true
   langTimer:connect_signal('timeout', function () langLay.visible = false end)
   langTimer:again()
end

return {toggle = langChange}
