local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")

local colors = require "colors"

local sidebarSize = 600 -- idk how to get it from sidebar.lua ¯\_(ツ)_/¯ 

local cpuLoad = wibox.widget {
   font = "Mononoki Nerd Font bold 14",
   text = "No info",

   valign = "center",
   halign = "center",

   widget = wibox.widget.textbox
}

local cpu = wibox.widget {
   {

      {
         {
            image = os.getenv ("HOME") .. "/.config/awesome/icons/feather_48px/cpu.svg",

            forced_width = 50,
            forced_height = 50,

            halign = "center",
            valign = "center",

            widget = wibox.widget.imagebox
         },

         top = 30,
         bottom = 20,
         widget = wibox.container.margin
      },

      cpuLoad,
      layout = wibox.layout.fixed.vertical
   },

   value = 0,
   max_value = 100,
   min_value = 0,
   
   color = colors.blue,
   border_color = colors.foreground,
   border_width = 15,

   widget = wibox.container.radialprogressbar
}

-- update cpu value
gears.timer {
   timeout = 3,
   autostart = true,
   callback = function ()
      awful.spawn.easy_async_with_shell ("mpstat 1 1 | grep Average | awk '{print $12}'", function (out)
                                            local idle = gears.string.split (out, "\n")[1]
                                            cpu.value = 100 - idle
                                            cpuLoad.text = tostring (100 - idle) ..  "%"
      end)
   end
}

local ramLoad = wibox.widget {
   font = "Mononoki Nerd Font bold 14",
   text = "No info",

   valign = "center",
   halign = "center",

   widget = wibox.widget.textbox
}

local ram = wibox.widget {

   {
      {
         {
            image = os.getenv ("HOME") .. "/.config/awesome/icons/feather_48px/database.svg",

            forced_width = 50,
            forced_height = 50,

            halign = "center",
            valign = "center",

            widget = wibox.widget.imagebox
         },

         top = 30,
         bottom = 20,
         widget = wibox.container.margin
      },

      ramLoad,
      layout = wibox.layout.fixed.vertical
   },

   value = 0,
   min_value = 0,
   max_value = 0,

   color = colors.orange,
   border_width = 15,
   border_color = colors.foreground,

   widget = wibox.container.radialprogressbar
}

-- Get RAM load
gears.timer {
   timeout = 3,
   autostart = true,
   callback = function ()
      awful.spawn.easy_async_with_shell ("free -m | grep Mem | awk 'OFS=\"|\" {print $3,$2}'", function (out)
                                            local currentRam = gears.string.split (out, "|")[1]
                                            local totalRam = gears.string.split(gears.string.split (out, "|")[2], "\n")[1]

                                            ram.max_value = tonumber (totalRam)
                                            ram.value = tonumber(currentRam)

                                            ramLoad.text = math.floor ((currentRam / 1000) * 100) / 100 .. " Gig"
      end)
   end
}

local discLoad = wibox.widget {
   font = "Mononoki Nerd Font bold 14",
   text = "No info",

   valign = "center",
   halign = "center",

   widget = wibox.widget.textbox
}

local disc =  wibox.widget {

   {
      {
         {
            image = os.getenv ("HOME") .. "/.config/awesome/icons/feather_48px/hard-drive.svg",

            halign = "center",
            valign = "center",

            forced_height = 50,
            forced_width = 50,

            widget = wibox.widget.imagebox
         },
         top = 30,
         bottom = 20,

         widget = wibox.container.margin
      },

      discLoad,
      layout = wibox.layout.fixed.vertical
   },

   value = 0,
   min_value = 0,
   max_value = 100,

   color = colors.majenta,
   border_width = 15,
   border_color = colors.foreground,

   widget = wibox.container.radialprogressbar
}

-- Get disc pecentage

gears.timer {
   timeout = 3,
   autostart = true,
   callback = function ()
      awful.spawn.easy_async_with_shell ("df -h /| grep / | awk '{print $5}' | sed 's/%//g'", function (out)
                                            local currentPercentage = gears.string.split (out, "\n")[1]
                                            disc.value = tonumber(currentPercentage)
                                            discLoad.text = currentPercentage .. '%'
      end)
   end
}

function backgroundContainer (wgt, marginSize, spacing)
   return wibox.widget {
      {
         wgt,

         forced_width = sidebarSize / 3 - spacing / 2, 
         forced_height = sidebarSize / 3 - spacing / 2,

         margins = marginSize,
         widget = wibox.container.margin
      },

      bg = colors.background2,
      widget = wibox.container.background
   }
end

-- TODO: Something wrong with disck contanier size 😩 
local systemResources = wibox.widget {
   backgroundContainer (cpu, 10, 10),
   backgroundContainer (ram, 10, 10),
   backgroundContainer (disc, 10, 10),

   spacing = 10,
   layout = wibox.layout.fixed.horizontal
}

return wibox.widget {
   systemResources,
   bottom = 10,
   widget = wibox.container.margin
}

