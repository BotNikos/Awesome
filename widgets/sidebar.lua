local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")

-- Widgets
local colors = require "colors"
local player = require "widgets/player"
local monitorToggler = require "widgets/monitorToggler"
local powerControl = require "widgets/power"
local compositorToggler = require "widgets/compositorToggler"
local calendar = require "widgets/calendar"

local togglersContainer = wibox.widget {
   monitorToggler,
   compositorToggler,

   layout = wibox.layout.ratio.horizontal
}

togglersContainer:set_ratio (1, 0.5)
togglersContainer:set_ratio (2, 0.5)

local sidebar = awful.popup {
   widget = {
      {
         player.widget,
         togglersContainer,
         powerControl,
         layout = wibox.layout.fixed.vertical
      },
      margins = 10,
      widget = wibox.container.margin
   },
   border_width = 2,
   screen = screen[1],
   placement = awful.placement.right,

   type = "normal",
   visible = false,
   ontop = true,
   border_color = colors.violet,
}

function toggle () 
   local currentScreen = awful.screen.focused()
   sidebar.screen = currentScreen
   sidebar.visible = not sidebar.visible
end

local sidebarCloseTimer = gears.timer {
   timeout = 1,
   single_shot = true,
   callback = function ()
      sidebar.visible = false
      player.selector.visible = false
   end
}

sidebar:connect_signal("mouse::leave", function () sidebarCloseTimer:again() end)
sidebar:connect_signal("mouse::enter", function () sidebarCloseTimer:stop() end)

player.selector:connect_signal("mouse::leave", function () sidebarCloseTimer:again() end)
player.selector:connect_signal("mouse::enter", function () sidebarCloseTimer:stop() end)

return {
   widget = sidebar,
   toggle = toggle
}
