local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")

local colors = require "colors"

local list = wibox.widget {
   spacing = 10,
   layout = wibox.layout.fixed.vertical
}

local mount = wibox.widget {
   {
      font = "Mononoki Nerd Font Bold 24",
      text = "Discs:",
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
      right = 70,
      widget = wibox.container.margin
   },

   list,

   widget = wibox.layout.fixed.vertical
}

local window = wibox {
   width = 300,
   height = 75,

   border_width = 2,
   border_color = colors.violet,

   widget = {
      mount,
      margins = 10,
      widget = wibox.container.margin
   },

   ontop = true,
   visible = false, 
}


-- TODO:
-- 1. Unmount function
-- 2. Hover effect
-- 3. Scroll

function toggle () 
   local currentScreen = awful.screen.focused ()

   window:geometry ({
         x = currentScreen.workarea.x + currentScreen.workarea.width - window.width - 15,
         y = currentScreen.workarea.y + 10 
   })

   awful.spawn.easy_async_with_shell ("lsblk | grep part | grep G | awk 'OFS=\"|\" {print $1, $4}' | cut -c 7-", function (out)
                                         list:reset ()

                                         local discsSplited = gears.string.split (out, '\n')
                                         discsSplited[gears.table.count_keys(discsSplited)] = nil -- delete last element

                                         window.height = gears.table.count_keys(discsSplited) * 50 + 75 

                                         for index, value in pairs (discsSplited) do
                                            list:add (wibox.widget {
                                                         {
                                                            {
                                                               {
                                                                  font = "Mononoki Nerd Font Bold 14",
                                                                  text = gears.string.split (value, "|")[1],

                                                                  forced_width = 120,

                                                                  widget = wibox.widget.textbox
                                                               },

                                                               {
                                                                  font = "Mononoki Nerd Font Bold 14",
                                                                  text = gears.string.split (value, "|")[2],

                                                                  forced_width = 120,

                                                                  halign = "center",
                                                                  valign = "center",

                                                                  widget = wibox.widget.textbox
                                                               },

                                                               {
                                                                  image = os.getenv ("HOME") .. "/.config/awesome/icons/feather_white/download.svg",
                                                                  forced_height = 20,
                                                                  forced_width = 20,
                                                                  halign = "right",
                                                                  valign = "center",
                                                                  widget = wibox.widget.imagebox
                                                               },

                                                               buttons = {
                                                                  awful.button ({}, 1, nil, function ()
                                                                        awful.spawn.easy_async_with_shell (terminal .. " sudo mount /dev/" .. gears.string.split (value, "|")[1] .. " ~/mnt", function () end)
                                                                  end)
                                                               },

                                                               layout = wibox.layout.fixed.horizontal
                                                            },
                                                            margins = 10,
                                                            widget = wibox.container.margin
                                                         },

                                                         bg = colors.background2,
                                                         widget = wibox.container.background
                                            })
                                         end

                                         for index, value in pairs (list.children) do
                                            value:connect_signal("mouse::enter", function () value.bg = colors.violet end)
                                            value:connect_signal("mouse::leave", function () value.bg = colors.background2 end)
                                         end
   end)

   window.visible = not window.visible
end

return {
   toggle = toggle
}

      
                   
