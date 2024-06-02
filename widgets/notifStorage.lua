local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")

local colors = require "colors"

local notifStorage = wibox.widget {
   spacing = 10,
   layout = wibox.layout.fixed.vertical
}

local textNothing = wibox.widget {
   font = "Mononoki Nerd Font Bold 28",
   markup = "<span foreground='" .. colors.foregroundDim .. "'>Nothing to display</span>",
   halign = "center",
   valign = "center",
   forced_height = 400,
   visible = true,
   widget = wibox.widget.textbox
}

local scrollWidget = wibox.widget.base.make_widget ()

local clearButton = wibox.widget {
   {
      {
         image = os.getenv ("HOME") .. "/.config/awesome/icons/feather_white/trash-2.svg",

         forced_width = 30,
         forced_height = 30,

         halign = "center",
         valign = "center",

         widget = wibox.widget.imagebox
      },

      margins = 10,
      widget = wibox.container.margin
   },

   buttons = {
      awful.button ({}, 1, nil, function ()
            notifStorage:reset ()
            textNothing.visible = true
      end)
   },
   
   layout = wibox.container.background
}

clearButton:connect_signal ("mouse::enter", function () clearButton.bg = colors.violet end)
clearButton:connect_signal ("mouse::leave", function () clearButton.bg = colors.background end)

local notifWidget = wibox.widget {
   {

      {
         {
            font = "Mononoki Nerd Font Bold 24",
            text = "Notifications:",
            valign = "center",
            halign = "left",
            forced_width = 550,
            widget = wibox.widget.textbox
         },

         clearButton,
         
         layout = wibox.layout.fixed.horizontal
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
         right = 200,
         widget = wibox.container.margin
      },

      textNothing,
      notifStorage,

      layout = wibox.layout.fixed.vertical
   },
   margins = 10,
   widget = wibox.container.margin
}

local scrollY = 0

function scrollWidget:layout (context, width, height)
   return { wibox.widget.base.place_widget_at (notifWidget, 0, scrollY, 620, 10000) }
end

local notifWin = wibox {
   width = 620,
   height = 500,

   widget = scrollWidget,
   border_width = 2,
   border_color = colors.violet,

   ontop = true,
   visible = false
}

-- scroll up
scrollWidget:add_button (awful.button ({}, 4, nil, function ()
                               if scrollY ~= 0 then
                                  scrollY = scrollY + 20 
                               end
                               scrollWidget:emit_signal ("widget::layout_changed")
end))

-- scroll down
scrollWidget:add_button (awful.button ({}, 5, nil, function ()
                               local notifCardHeight = 85 
                               local notifWinHeight = 500 
                               local notifWinTitleHeight = 70 

                               local contentHeight = gears.table.count_keys(notifStorage.children) * notifCardHeight + notifWinTitleHeight

                               if contentHeight - notifWinHeight > 0 and math.abs (scrollY) <= contentHeight - notifWinHeight then
                                  scrollY = scrollY - 20 
                               end
                               scrollWidget:emit_signal ("widget::layout_changed")
end))

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

   scrollY = 0
   scrollWidget:emit_signal ("widget::layout_changed")

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
                                                      image = notif.icon,
                                                      halign = "center",
                                                      valign = "center",
                                                      forced_width = 50,
                                                      forced_height = 50,
                                                      widget = wibox.widget.imagebox
                                                   },

                                                   {

                                                      {
                                                         {
                                                            font = "Mononoki Nerd Font Bold 20",
                                                            text = notif.title,
                                                            widget = wibox.widget.textbox
                                                         },

                                                         step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
                                                         speed = 100,
                                                         set_fps = 60,

                                                         layout = wibox.container.scroll.horizontal,

                                                      },

                                                      {
                                                         {
                                                            font = "Mononoki Nerd Font Bold 16",
                                                            text = notif.text,
                                                            widget = wibox.widget.textbox
                                                         },

                                                         step_function = wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
                                                         speed = 100,
                                                         set_fps = 60,

                                                         layout = wibox.container.scroll.horizontal,
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

-- Scrollable container example
---------------------------------------------------------

-- local w = wibox { x = 100,
--                  y = 100,

--                  width = 100,
--                  height = 100,

--                  border_width = 2,
--                  border_color = colors.violet,

--                  ontop = true,
--                  visible = true
-- }

-- my_wiget = function()
--    return wibox.widget {
--       text = "H\nE\nL\nL\nO\n \nW\nO\nR\nL\nD\n",
--       widget = wibox.widget.textbox
--    }

-- end

-- local own_widget = wibox.widget.base.make_widget()
-- local offset_x, offset_y = 0, 0
-- function own_widget:layout(context, width, height)
--     -- No idea how to pick good widths and heights for the inner widget.
--    return { wibox.widget.base.place_widget_at(my_wiget (), offset_x, offset_y, 100, 100) }
-- end

-- own_widget:buttons(
--     awful.util.table.join(
--         awful.button(
--             {},
--             4,
--             function()
--                 if offset_y <= 490 then
--                     offset_y = offset_y + 5
--                 end
--                 own_widget:emit_signal("widget::layout_changed")
--             end
--         ),
--         awful.button(
--             {},
--             5,
--             function()
--                 if offset_y >= 5 then
--                     offset_y = offset_y - 5
--                 end
--                 own_widget:emit_signal("widget::layout_changed")
--             end
--         )
--     )
-- )

-- w:set_widget(own_widget)


return {
   toggle = toggle,
   widget = notifWin,
}
