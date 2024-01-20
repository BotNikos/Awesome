local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
local beautiful = require ("beautiful")
require("awful.hotkeys_popup.keys")

-- colors
background = "#282A36"
background2 = "#383A59"
foreground = "#F4F4EF"
violet = "#BD93F9"
orange = "#FF9C32"
majenta = "#FF79C6"
blue = "#7CCCDF"

systemInfo = awful.popup {
   widget = {
      {
         {
            -- image = "~/.config/awesome/icons/featherIcons/volume.svg",
            resize = true,
            upscale = true,
            forced_width = 50,
            forced_height = 50,
            image = "~/pokemons/mew.png",
            widget = wibox.widget.imagebox
         },
         layout = wibox.layout.fixed.vertical
      },
      margins = 10,
      widget = wibox.container.margin
   },
   border_width = 2,
   screen = screen[1],
   placement = awful.placement.right,

   visible = false,
   ontop = true,
   border_color = violet,
}

local keyboardlayout = 'ru'
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
   border_color = violet,
   screen = screen[1],
   placement = awful.placement.centered,
   visible = false,
   ontop = true
}

function langChange ()
   keyboardlayout = keyboardlayout == "ru" and "us" or "ru"
   langLay.widget.widget.text = string.upper(keyboardlayout)
   langLay.visible = true
   langTimer:connect_signal('timeout', function () langLay.visible = false end)
   langTimer:again()
end

local volumeTimer = gears.timer {
   timeout = 2,
   single_shot = true,
}

local volumeMeter = awful.popup {

   widget = {

      {
         max_value = 10,
         value = 5,
         paddings = 5,
         forced_width = 500,
         forced_height = 50,
         border_color = violet,
         color = violet,
         background_color = background,
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
      awful.spawn("pamixer -i 10")
   else
      awful.spawn("pamixer -d 10")
   end

   awful.spawn.easy_async_with_shell ("pamixer --get-volume", function (out)
                                         local volumeLevel = math.floor(out / 10)
                                         volumeMeter : setup {

                                            {
                                               max_value = 10,
                                               value = volumeLevel,
                                               paddings = 5,
                                               forced_width = 500,
                                               forced_height = 50,
                                               border_color = violet,
                                               color = violet,
                                               background_color = background,
                                               border_width = 2,
                                               widget = wibox.widget.progressbar
                                            },

                                            {
                                               font = "Fira Code Bold 25",
                                               text = tostring (volumeLevel) .. "/10",
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
                                                  image = os.getenv ("HOME") .. "/.config/awesome/icons/feather_24px/volume.svg",
                                                  widget = wibox.widget.imagebox 
                                               },

                                               left = 180,
                                               top = 12,
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
   systemInfo = systemInfo,
   langChange = langChange,
   volumeChange = volumeChange
} 
