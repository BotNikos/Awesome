local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")

local colors = require "colors"

local currentPlayer = "spotify"
local lastIconPath = ""

local playerIconBlank = wibox.widget {
      resize = true,
      forced_width = 150,
      forced_height = 150,
      widget = wibox.widget.imagebox
}

local playerIcon = awful.widget.watch ("playerctl metadata -p " .. currentPlayer .. " --format '{{mpris:artUrl}}'", 1, function (widget, out)
                                          if out ~= lastIconPath then
                                             awful.spawn.easy_async_with_shell ("curl -o ~/.config/awesome/tmp/playerIcon.png " .. out, function ()
                                                                                   widget.image = gears.surface.load_uncached (os.getenv ("HOME") .. "/.config/awesome/tmp/playerIcon.png")
                                             end)
                                          end
end, playerIconBlank)

local playerTitleBlank = wibox.widget {
   font = "Mononoki Nerd Font Bold 24",
   text = "Here need to be song title",
   forced_height = 40,
   widget = wibox.widget.textbox
}

local playerTitle = awful.widget.watch ("playerctl metadata -p " .. currentPlayer .. " --format '{{title}}'", 1, function (widget, out)
                                           widget.text = (out ~= "") and out or "Nothing plays"
end, playerTitleBlank)

-- TODO: create popup with all available players
local selectorIcon = wibox.widget {
   {
      image = os.getenv ("HOME") .. '/.config/awesome/icons/feather_48px/chevron-down.svg',
      forced_width = 24,
      forced_height = 24,
      halign = "center",
      widget = wibox.widget.imagebox
   },

   buttons = {
      awful.button ({}, 1, nil, function () naughty.notify {message = "Hello ?"} end)
   },

   bg = colors.background2,
   widget = wibox.container.background
}

selectorIcon:connect_signal("mouse::enter", function () selectorIcon.bg = colors.violet end)
selectorIcon:connect_signal("mouse::leave", function () selectorIcon.bg = colors.background2 end)

local titleContainer = wibox.widget {

   playerTitle,
   selectorIcon,

   layout = wibox.layout.ratio.horizontal
}

titleContainer:set_ratio (1, 0.9)
titleContainer:set_ratio (2, 0.1)

local playerAuthorBlank = wibox.widget {
   font = "Mononoki Nerd Font 14",
   text = "Here need to be song author",
   widget = wibox.widget.textbox
}

local playerAuthor = awful.widget.watch ("playerctl metadata -p " .. currentPlayer .. " --format '{{artist}}'", 1, function (widget, out)
                                            widget.text = (out ~= "") and out or "Turn on some song"
end, playerAuthorBlank)

function timeToSec (time)
   local timeSplited = gears.string.split(time, ":")
   return tonumber(timeSplited[1]) * 60 + tonumber(timeSplited[2]) -- 60 seconds in minute
end

-- TODO: Add fuction to seek track
local playerProgressBlank = wibox.widget {
   value = 25,
   max_value = 100,
   color = colors.violet,
   background_color = colors.foreground,
   forced_height = 35,
   margins = {
      top = 15,
      bottom = 15
   },

   widget = wibox.widget.progressbar,
}

local playerTime = wibox.widget {
   font = "Mononoki Nerd Font 14",
   text = "0:00/0:00",
   widget = wibox.widget.textbox
}

local playerProgress = awful.widget.watch ("playerctl metadata -p " .. currentPlayer .. " --format '{{duration(position)}}|{{duration(mpris:length)}}'", 1, function (widget, out)
                                              outSplited = gears.string.split (out, "|")
                                              widget.value = timeToSec(outSplited[1])
                                              widget.max_value = timeToSec(outSplited[2])

                                              maxTimeTrimmed = gears.string.split (outSplited[2], "\n")
                                              playerTime.text = outSplited[1] .. "/" .. maxTimeTrimmed[1]
end, playerProgressBlank)

local progressContainer = wibox.widget {
   {
      playerProgress,
      right = 10,
      widget = wibox.container.margin
   },
   playerTime,
   forced_width = 430,
   layout = wibox.layout.ratio.horizontal
}

progressContainer:set_ratio(1, 0.75)
progressContainer:set_ratio(2, 0.25)

local buttonPrevious = wibox.widget {
   {
      image = os.getenv ("HOME") .. "/.config/awesome/icons/feather_48px/skip-back.svg",
      halign = 'center',
      buttons = {
         awful.button ({}, 1, nil, function () awful.spawn ("playerctl previous") end)
      },
      widget = wibox.widget.imagebox 
   },
   widget = wibox.container.background
}

buttonPrevious:connect_signal("mouse::enter", function () buttonPrevious.bg = colors.violet end)
buttonPrevious:connect_signal("mouse::leave", function () buttonPrevious.bg = colors.background2 end)

-- TODO: Toggle icon after click
local buttonTogglePause = wibox.widget {
   {
      image = os.getenv ("HOME") .. "/.config/awesome/icons/feather_48px/pause.svg",
      forced_width = buttonSize,
      forced_height = buttonSize,
      halign = 'center',
      buttons = {
         awful.button ({}, 1, nil, function () awful.spawn ("playerctl play-pause") end)
      },
      widget = wibox.widget.imagebox 
   },
   widget = wibox.container.background
}

buttonTogglePause:connect_signal("mouse::enter", function () buttonTogglePause.bg = colors.violet end)
buttonTogglePause:connect_signal("mouse::leave", function () buttonTogglePause.bg = colors.background2 end)

local buttonNext = wibox.widget {
   {
      image = os.getenv ("HOME") .. "/.config/awesome/icons/feather_48px/skip-forward.svg",
      forced_width = buttonSize,
      forced_height = buttonSize,
      halign = 'center',
      buttons = {
         awful.button ({}, 1, nil, function () awful.spawn ("playerctl next") end)
      },
      widget = wibox.widget.imagebox 
   },
   widget = wibox.container.background
}

buttonNext:connect_signal("mouse::enter", function () buttonNext.bg = colors.violet end)
buttonNext:connect_signal("mouse::leave", function () buttonNext.bg = colors.background2 end)

local buttonSize = 50
local buttonsContainer = wibox.widget {
   buttonPrevious,
   buttonTogglePause,
   buttonNext,
   forced_height = buttonSize,
   layout = wibox.layout.flex.horizontal
}

local player = wibox.widget {
   {
      {
         playerIcon,
         {
            titleContainer,
            playerAuthor,
            progressContainer,
            buttonsContainer,
            layout = wibox.layout.fixed.vertical
         },
         spacing = 15,
         layout = wibox.layout.fixed.horizontal
      },

      margins = 10,
      widget = wibox.container.margin
   },

   bg = colors.background2,
   forced_width = 600,
   widget = wibox.container.background
}

return player
