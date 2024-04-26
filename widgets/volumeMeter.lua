local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")

local volumeTimer = gears.timer {
   timeout = 2,
   single_shot = true,
}

local volumeMeter = awful.popup {

   widget = {

      {
         max_value = 100,
         value = 50,
         paddings = 5,
         forced_width = 500,
         forced_height = 50,
         border_color = colors.violet,
         color = colors.violet,
         background_color = colors.background,
         border_width = 2,
         widget = wibox.widget.progressbar,
      },

      {
         widget = wibox.widget.textbox
      },

      layout = wibox.layout.stack
   },

   x = 0,
   y = 0,
   screen = screen[1],
   ontop = true,
   visible = false
}

function volumeChange (action)
   if action == "increase" then
      awful.spawn("pamixer -i 1")
   else
      awful.spawn("pamixer -d 1")
   end

   awful.spawn.easy_async_with_shell ("pamixer --get-volume", function (out)
                                         local volumeLevel = tonumber (out)
                                         volumeMeter : setup {

                                            {
                                               max_value = 100,
                                               value = volumeLevel,
                                               paddings = 5,
                                               forced_width = 500,
                                               forced_height = 50,
                                               border_color = colors.violet,
                                               color = colors.violet,
                                               background_color = colors.background,
                                               border_width = 2,
                                               widget = wibox.widget.progressbar
                                            },

                                            {
                                               font = "Fira Code Bold 25",
                                               text = tostring (volumeLevel) .. "/100",
                                               align = "center",
                                               valign = "center",
                                               halign = "center",
                                               widget = wibox.widget.textbox
                                            },

                                            {
                                               {
                                                  resize = false,
                                                  align = "center",
                                                  valign = "center",
                                                  halign = "center",
                                                  image = os.getenv ("HOME") .. "/.config/awesome/icons/feather_48px/volume.svg",
                                                  widget = wibox.widget.imagebox 
                                               },

                                               left = 170,
                                               top = 1,
                                               widget = wibox.container.margin,
                                            },

                                            forced_width = 500,
                                            layout = wibox.layout.stack
                                                             }

   end)

   local currentScreen = awful.screen.focused ()
   volumeMeter.screen = currentScreen

   volumeMeter.x = (currentScreen.workarea.width / 2 - 500 / 2) + currentScreen.workarea.x -- 500 is volumeMeter width
   volumeMeter.y = (currentScreen.workarea.height / 10) * 8 + currentScreen.workarea.y -- 80 percent of current screen height
   
   volumeMeter.visible = true
   volumeTimer:connect_signal('timeout', function () volumeMeter.visible = false end)
   volumeTimer:again()

end

return {
   change = volumeChange
} 
