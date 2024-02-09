local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")

local popups = require "widgets/popups"
local keys = gears.table.join (

   awful.key({modkey}, "i",
      function ()
         local currentScreen = awful.screen.focused()

         popups.systemInfo.screen = currentScreen

         -- popups.systemInfo.minimum_width = currentScreen.workarea.width / 3
         -- popups.systemInfo.minimum_height = currentScreen.workarea.height - uselessGap - 15
         -- popups.systemInfo.widget.widget.widget.text = "Hello world!"

         popups.systemInfo.visible = not popups.systemInfo.visible
      end,
      {description="Open system info", group="popups"}),

    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help, {description="show help", group="awesome"}),

    -- Selecting active client 
    awful.key({modkey, }, "j", function () awful.client.focus.bydirection("down") end, {description = "focus window below", group = "client"}),
    awful.key({modkey, }, "k", function () awful.client.focus.bydirection("up") end, {description = "focus window above", group = "client"}),
    awful.key({modkey, }, "h", function () awful.client.focus.bydirection("left") end, {description = "focus window left", group = "client"}),
    awful.key({modkey, }, "l", function () awful.client.focus.bydirection("right") end, {description = "focus window right", group = "client"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.bydirection("down")    end,
              {description = "swap with lower client", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.bydirection("up")    end,
              {description = "swap with upper client", group = "client"}),
    awful.key({ modkey, "Shift"   }, "h", function () awful.client.swap.bydirection("left")    end,
              {description = "swap with left client", group = "client"}),
    awful.key({ modkey, "Shift"   }, "l", function () awful.client.swap.bydirection("right")    end,
              {description = "swap with right client", group = "client"}),

    -- Screen changing
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_bydirection("down") end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_bydirection("up") end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "h", function () awful.screen.focus_bydirection("left") end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "l", function () awful.screen.focus_bydirection("right") end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    -- Application size on screen
    awful.key({ modkey,           }, ".",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, ",",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),

    awful.key({ modkey,           }, "i",     function () awful.client.incwfact( 0.1)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "m",     function () awful.client.incwfact(-0.1)          end,
              {description = "decrease master width factor", group = "layout"}),

    awful.key({ modkey, "Shift"   }, ",",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, ".",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),

    awful.key({ modkey,           }, "Tab", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),

    -- Launcher
    awful.key({modkey}, "r", function () awful.spawn("rofi -show drun") end, {description = "Run rofi", group = "launcher"}),

    -- Custom keybindings
    awful.key({modkey, "Shift"}, "m",
       function ()
          awful.spawn("spotify")
       end,
       {decription = "Run spotify", group = "applications"}
    ),

    awful.key({modkey}, "e",
       function ()
          awful.spawn("emacsclient -c --eval '(load-file \"~/.emacs.d/init.el\")'")
       end,
       {decription = "Run emacs daemon", group = "applications"}
    ),

    awful.key({modkey}, "b",
       function ()
          awful.spawn("qutebrowser")
       end,
       {description = "Run qutebrowser", group = "applications"}
    ),

    -- change keyboard layout
    awful.key({modkey}, "space", function () popups.langChange() end, {description = "Change layout", group = "applications"}
    ),

    -- pavucontrol
    awful.key({modkey, "Shift"}, "v", function () awful.spawn("pavucontrol") end, {description = "Open pavucontrol", group = "applications"}),

    -- player contorl
    awful.key({ modkey, }, "p", function () awful.spawn("playerctl play-pause") end, {description = "Toggle player", group = "multimedia"}),
    awful.key({ modkey, }, "]", function () awful.spawn("playerctl next") end, {description = "Next player", group = "multimedia"}),
    awful.key({ modkey, }, "[", function () awful.spawn("playerctl previous") end, {description = "Back player", group = "multimedia"}),

    awful.key({ modkey, }, "=", function () popups.volumeChange("increase") end, {description = "Increase volume by 10", group = "multimedia"}),
    awful.key({ modkey, }, "-", function () popups.volumeChange("decrease") end, {description = "Decrease volume by 10", group = "multimedia"})
)

local clientkeys = gears.table.join(
    awful.key({modkey}, "f", function (c) c.fullscreen = not c.fullscreen c:raise() end, {description = "toggle fullscreen", group = "client"}),
    awful.key({modkey, "Shift"}, "f", function (c) c.floating = not c.floating end, {description = "toggle floating", group = "client"}),
    awful.key({modkey, "Shift"}, "c", function (c) c:kill() end, {description = "close", group = "client"}),
    awful.key({modkey}, "t", function (c) c.ontop = not c.ontop end, {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey, "Shift" }, "m", function (c) c.maximized = false c.maximized_vertical=false c.maximized_horizontal=false c:raise() end, {description = "demaximize", group = "client"})
)

return {
   keys = keys,
   clientkeys = clientkeys,
}
