local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")

local colors = require "colors"

-- TODO:
-- Reset widget when sidebar opens
-- A notification style
local notifStorage = wibox.widget {
   spacing = 10,
   layout = wibox.layout.fixed.vertical
}

--scroll up
notifStorage:add_button (awful.button ({}, 4, nil, function ()
      local tableLen = gears.table.count_keys (notifStorage.children)
      for index, value in pairs (notifStorage.children) do
         notifStorage:swap (index, tableLen)
      end
end))

-- scroll down
notifStorage:add_button (awful.button ({}, 5, nil, function ()
      for index, value in pairs (notifStorage.children) do
         notifStorage:swap (index, index - 1)
      end
end))

naughty.connect_signal ('added', function (notif)
                           notifStorage:insert (1, wibox.widget {
                                             {
                                                {
                                                   {
                                                      font = "Mononoki Nerd Font Bold 14",
                                                      text = notif.title,
                                                      widget = wibox.widget.textbox
                                                   },

                                                   {
                                                      font = "Mononoki Nerd Font Bold 12",
                                                      text = notif.text,
                                                      widget = wibox.widget.textbox
                                                   },

                                                   layout = wibox.layout.fixed.vertical
                                                },

                                                margins = 10,
                                                widget = wibox.container.margin
                                             },

                                             bg = colors.background2,
                                             widget = wibox.container.background 
                           })
end)

local notifWin = wibox {
   width = 620,
   height = 500,

   widget = wibox.widget {
      {
         {
            font = "Mononoki Nerd Font Bold 24",
            text = "Notifications:",
            valign = "center",
            halign = "center",
            widget = wibox.widget.textbox
         },

         {
            {
               orientation = "horizontal",
               forced_height = 6,
               thickness = 2,
               span_ratio = 0.8,
               color = colors.violet,

               widget = wibox.widget.separator
            },

            top = 3,
            bottom = 10,
            widget = wibox.container.margin
         },

         notifStorage,
         layout = wibox.layout.fixed.vertical
      },
      margins = 10,
      widget = wibox.container.margin
   },

   border_width = 2,
   border_color = colors.violet,

   ontop = true,
   visible = false
}

function toggle ()
   local currentScreen = awful.screen.focused ()

   notifWin:geometry ({
         x = currentScreen.workarea.x + currentScreen.workarea.width - notifWin.width - 15,
         y = currentScreen.workarea.y + 10 
   })

   notifWin.visible = not notifWin.visible
end

return {
   toggle = toggle,
   widget = notifWin,
}
