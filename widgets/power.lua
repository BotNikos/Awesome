local awful = require("awful")
local wibox = require("wibox")

local colors = require "colors"

local reboot = wibox.widget {
   {
      {
         image = os.getenv ("HOME") .. "/.config/awesome/icons/feather_48px/rotate-ccw.svg",
         forced_width = 50,
         forced_height = 50,
         halign = "center",
         widget = wibox.widget.imagebox
      },

      margins = 10,
      widget = wibox.container.margin
   },

   buttons = {
      awful.button ({}, 1, nil, function () awful.spawn ("reboot") end)
   },

   bg = colors.background2,
   widget = wibox.container.background
}

reboot:connect_signal("mouse::enter", function () reboot.bg = colors.violet end)
reboot:connect_signal("mouse::leave", function () reboot.bg = colors.background2 end)

local logout = wibox.widget {
   {
      {
         image = os.getenv ("HOME") .. "/.config/awesome/icons/feather_48px/log-out.svg",
         forced_width = 50,
         forced_height = 50,
         halign = "center",
         widget = wibox.widget.imagebox
      },

      margins = 10,
      widget = wibox.container.margin
   },

   buttons = {
      awful.button ({}, 1, nil, function () awesome.quit () end)
   },

   bg = colors.background2,
   widget = wibox.container.background
}

logout:connect_signal("mouse::enter", function () logout.bg = colors.violet end)
logout:connect_signal("mouse::leave", function () logout.bg = colors.background2 end)

local shutdown = wibox.widget {
   {
      {
         image = os.getenv ("HOME") .. "/.config/awesome/icons/feather_48px/power.svg",
         forced_width = 50,
         forced_height = 50,
         halign = "center",
         widget = wibox.widget.imagebox
      },

      margins = 10,
      widget = wibox.container.margin,
   },

   buttons = {
      awful.button ({}, 1, nil, function () awful.spawn ('shutdown now') end)
   },

   bg = colors.background2,
   widget = wibox.container.background
}

shutdown:connect_signal("mouse::enter", function () shutdown.bg = colors.violet end)
shutdown:connect_signal("mouse::leave", function () shutdown.bg = colors.background2 end)

local powerControl = wibox.widget {
   reboot,
   logout,
   shutdown,

   spacing = 10,
   widget = wibox.layout.flex.horizontal
}

return powerControl
