local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")

local colors = require "colors"

-- TODO:
-- Reset widget when sidebar opens
-- Clear all notifications
-- Normal scrolling
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


local textNothing = wibox.widget {
   font = "Mononoki Nerd Font Bold 28",
   markup = "<span foreground='" .. colors.foregroundDim .. "'>Nothing to display</span>",
   halign = "center",
   valign = "center",
   forced_height = 400,
   visible = true,
   widget = wibox.widget.textbox
}

local notifWidget = wibox.widget {
   {
      {
         font = "Mononoki Nerd Font Bold 24",
         text = "Notifications:",
         valign = "center",
         halign = "left",
         widget = wibox.widget.textbox
      },

      {
         {
            orientation = "horizontal",
            forced_height = 6,
            thickness = 2,
            span_ratio = 1,
            color = colors.violet,

            widget = wibox.widget.separator
         },

         top = 3,
         bottom = 10,
         widget = wibox.container.margin
      },

      textNothing,
      notifStorage,

      layout = wibox.layout.fixed.vertical
   },
   margins = 10,
   widget = wibox.container.margin
}

local notifWin = wibox {
   width = 620,
   height = 500,

   widget = notifWidget,
   border_width = 2,
   border_color = colors.violet,

   ontop = true,
   visible = false
}

local closeTimer = gears.timer {
   timeout = 1,
   single_shot = true,
   callback = function ()
      notifWin.visible = false
   end
}

notifWin:connect_signal("mouse::leave", function () closeTimer:again() end)
notifWin:connect_signal("mouse::enter", function () closeTimer:stop() end)

function toggle ()
   local currentScreen = awful.screen.focused ()

   notifWin:geometry ({
         x = currentScreen.workarea.x + currentScreen.workarea.width - notifWin.width - 15,
         y = currentScreen.workarea.y + 10 
   })

   notifWin.visible = not notifWin.visible
end

naughty.connect_signal ('added', function (notif)
                           textNothing.visible = false
                           notifStorage:insert (1, wibox.widget {
                                             {
                                                {
                                                   {
                                                      image = notif.image,
                                                      forced_width = 80,
                                                      forced_height = 80,
                                                      widget = wibox.widget.imagebox
                                                   },

                                                   {
                                                      {
                                                         font = "Mononoki Nerd Font Bold 20",
                                                         text = notif.title,
                                                         widget = wibox.widget.textbox
                                                      },

                                                      {
                                                         font = "Mononoki Nerd Font Bold 16",
                                                         text = notif.text,
                                                         widget = wibox.widget.textbox
                                                      },

                                                      layout = wibox.layout.fixed.vertical
                                                   },

                                                   spacing = 10,
                                                   layout = wibox.layout.fixed.horizontal
                                                },

                                                margins = 10,
                                                widget = wibox.container.margin
                                             },

                                             bg = colors.background2,
                                             widget = wibox.container.background 
                           })
end)

return {
   toggle = toggle,
   widget = notifWin,
}
