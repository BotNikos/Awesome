local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local naughty = require("naughty")

local colors = require "colors"

local currentPlayer = ""
local lastIconPath = ""

local playerIcon = wibox.widget {
      resize = true,
      forced_width = 150,
      forced_height = 150,
      halign = 'center',
      valign = 'center',
      widget = wibox.widget.imagebox
}

local playerTitle = wibox.widget {
   font = "Mononoki Nerd Font Bold 24",
   text = "Here need to be song title",
   forced_height = 40,
   widget = wibox.widget.textbox
}

local selectorLabelsBlank = wibox.widget {
   layout = wibox.layout.fixed.vertical
}

local allPlayers = {}
local playersCount = 0
local selectorLabels = awful.widget.watch ("playerctl -l", 1, function (widget, out)
                                              local players = gears.string.split (out, "\n")
                                              playersCount = gears.table.count_keys(players)
                                              players[playersCount] = nil -- delete "\n" (last) element

                                              if (allPlayers ~= out) then
                                                 widget:reset()
                                                 for index, value in pairs (players) do
                                                    widget:add (wibox.widget {
                                                                   text = value,
                                                                   font = "Mononoki Nerd Font Bold 14",

                                                                   forced_height = 30,

                                                                   buttons = {
                                                                      awful.button ({}, 1, nil, function () updateSelectedPlayer (value) end)
                                                                   },

                                                                   widget = wibox.widget.textbox
                                                    })
                                                 end
                                              end

                                              if gears.table.hasitem (allPlayers, currentPlayer) == nil then
                                                 currentPlayer = ""

                                                 widget:add (wibox.widget {
                                                                text = "Not found",
                                                                font = "Mononoki Nerd Font Bold 14",
                                                                forced_height = 30,
                                                                widget = wibox.widget.textbox
                                                 })
                                              end

                                              if playersCount > 0 and currentPlayer == "" then
                                                    currentPlayer = players[1]
                                              end

                                              allPlayers = players

end, selectorLabelsBlank)

local selectorPopup = awful.popup {
   widget = {
      selectorLabels,
      margins = 10,
      forced_width = 130,
      widget = wibox.container.margin,
   },


   visible = false,
   ontop = true,
   border_width = 2,
   border_color = colors.violet,
}

local selectorIcon = wibox.widget {
   {
      image = os.getenv ("HOME") .. '/.config/awesome/icons/feather_48px/chevron-down.svg',
      forced_width = 24,
      forced_height = 24,
      halign = "center",
      widget = wibox.widget.imagebox
   },

   buttons = {awful.button ({}, 1, nil, function ()
                    local sidebar = mouse.object_under_pointer ()

                    selectorPopup.x = sidebar.x + sidebar.width - 130 - 22 -- 130 is selectorPopup width, 22 - right offset 
                    selectorPopup.y = mouse.object_under_pointer().y + 22 + 40 -- 22 - top offset, 40 - icon height
                    selectorPopup.visible = not selectorPopup.visible
   end)},

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

local playerAuthor = wibox.widget {
   font = "Mononoki Nerd Font 14",
   text = "Here need to be song author",
   widget = wibox.widget.textbox
}

function timeToSec (time)
   local timeSplited = gears.string.split(time, ":")

   if gears.table.count_keys(timeSplited) < 3 then
      return tonumber(timeSplited[1]) * 60 + tonumber(timeSplited[2]) -- 60 seconds in minute
   else
      return tonumber(timeSplited[1]) * 3600 + tonumber(timeSplited[2]) * 60 + tonumber(timeSplited[3])
   end
end

local playerProgress = wibox.widget {
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
   halign = "right",
   widget = wibox.widget.textbox
}

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

local status = "Stopped"
local updateTimer = gears.timer {
   timeout = 1,
   autostart = true,
   callback = function ()
      checkStatus () -- asign current status to status var on 173 line
      if playersCount ~= 0 and currentPlayer ~= "" and status ~= "Stopped" then
         imageUpdate ()
         updateTitle ()
         updateAuthor ()
         updateProgress ()
      end
   end
}

function checkStatus ()
   awful.spawn.easy_async_with_shell ('playerctl -p ' .. currentPlayer .. ' status', function (out)
                                         local statusTrimmed = gears.string.split (out, '\n') 
                                         status = statusTrimmed[1]
   end)
end

function updateSelectedPlayer (player)
   currentPlayer = player 
   updateTimer:emit_signal('timeout')
   selectorPopup.visible = false
end

-- TODO: image if song not playing
function imageUpdate ()
   awful.spawn.easy_async_with_shell ("playerctl metadata -p " .. currentPlayer .. " --format '{{mpris:artUrl}}'", function (out)
                                             if out ~= lastIconPath then
                                                awful.spawn.easy_async_with_shell ("curl -o ~/.config/awesome/tmp/playerIcon.png " .. out, function ()
                                                                                      playerIcon.image = gears.surface.load_uncached (os.getenv ("HOME") .. "/.config/awesome/tmp/playerIcon.png")
                                                end)
                                             end
   end)
end

function updateTitle ()
   awful.spawn.easy_async_with_shell ("playerctl metadata -p " .. currentPlayer .. " --format '{{title}}'", function (out)
                                           playerTitle.text = (out ~= "") and out or "Nothing plays"
   end)
end

function updateAuthor ()
   awful.spawn.easy_async_with_shell ("playerctl metadata -p " .. currentPlayer .. " --format '{{artist}}'", function (out)
                                               playerAuthor.text = (out ~= "") and out or "Turn on some song"
   end)
end

function updateProgress ()
   awful.spawn.easy_async_with_shell ("playerctl metadata -p " .. currentPlayer .. " --format '{{duration(position)}}|{{duration(mpris:length)}}'", function (out)
                                                 outSplited = gears.string.split (out, "|")
                                                 playerProgress.value = timeToSec(outSplited[1])
                                                 playerProgress.max_value = timeToSec(outSplited[2])

                                                 maxTimeTrimmed = gears.string.split (outSplited[2], "\n")
                                                 playerTime.text = outSplited[1] .. "/" .. maxTimeTrimmed[1]

                                                 if playerProgress.max_value >= 600 then
                                                    progressContainer:set_ratio(1, 0.7)
                                                    progressContainer:set_ratio(2, 0.3)
                                                 elseif playerProgress.max_value >= 3600 then
                                                    progressContainer:set_ratio(1, 0.6)
                                                    progressContainer:set_ratio(2, 0.4)
                                                 else
                                                    progressContainer:set_ratio(1, 0.75)
                                                    progressContainer:set_ratio(2, 0.25)
                                                 end
   end)
end


local buttonPrevious = wibox.widget {
   {
      image = os.getenv ("HOME") .. "/.config/awesome/icons/feather_48px/skip-back.svg",
      halign = 'center',
      buttons = {
         awful.button ({}, 1, nil, function () awful.spawn ("playerctl -p " .. currentPlayer .. " previous") end)
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
         awful.button ({}, 1, nil, function () awful.spawn ("playerctl -p " .. currentPlayer .. " play-pause") end)
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
         awful.button ({}, 1, nil, function () awful.spawn ("playerctl -p " .. currentPlayer .. " next") end)
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
   -- forced_width = 600,
   widget = wibox.container.background
}

return {
   widget = player,
   selector = selectorPopup
} 
