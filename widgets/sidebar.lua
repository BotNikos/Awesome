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
local systemResources = require "widgets/systemResources"
local updates = require "widgets/updates"

local notifStorage = require "widgets/notifStorage"

local togglersContainer = wibox.widget {
   monitorToggler,
   compositorToggler,

   spacing = 10,
   layout = wibox.layout.flex.horizontal
}

-- TODO: Add spacing property to widgets layout, and delete all margins in childs
local sidebar = awful.popup {
   widget = {
      {
         player.widget,
         notifStorage,
         updates,
         systemResources,
         togglersContainer, -- contains monitortoggler and compositortoggler
         powerControl,

         forced_width = 600,

         spacing = 10,
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
