local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")

local colors = require "colors"

local container = wibox.widget {
}

-- local text = wibox.widget {
--    text = "0",
--    widget = wibox.widget.textbox
-- }

-- wibox {
--    x = 100,
--    y = 100,
--    width = 1000,
--    height = 20,
--    widget = text,
--    border_width = 2,
--    border_color = colors.violet,
--    ontop = true,
--    visible = true
-- }

local notifStorage = wibox.widget {
   spacing = 10,
   forced_height = 200,
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

return notifStorage

