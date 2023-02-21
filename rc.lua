-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- local lain = require("lain")
local testLayout = require "mylayout"

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

beautiful.init("~/.config/awesome/theme.lua")
terminal = "alacritty"
editor = "emacs" 
editor_cmd = terminal .. " -e " .. editor

modkey = "Mod4"
altKey = "Mod1"


-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    -- testLayout,
    -- lain.layout.uselesstile,
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}

-- {{{ Menu
-- Create a launcher widget and a main menu

myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

-- mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
--                                      menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()
mytextclock.format = " %d/%m/%Y %I:%M:%S %p "
mytextclock.refresh = 1
mytextclock.timezone = "+00:00"

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)


-- colors
background = "#282A36"
background2 = "#383A59"
foreground = "#F4F4EF"
violet = "#BD93F9"
orange = "#FF9C32"
majenta = "#FF79C6"
blue = "#7CCCDF"

for s in screen do
    awful.tag({ "Code", "Music", "Browser", "Terminal"}, s, awful.layout.layouts[2])

    -- naughty.notify({title = "Test", text = tostring(s.index), timeout = 0})

    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
       screen  = s,
       filter  = awful.widget.taglist.filter.all,
       buttons = taglist_buttons,
       style = {
          shape = gears.shape.rectangle,
       },
       widget_template = {
          {
            {
                {
                    {
                    {
                        id = 'text_role',
                        widget = wibox.widget.textbox,
                    },
                    layout = wibox.layout.fixed.horizontal  
                    },
                    widget = wibox.container.margin,
                    left = 10,
                    right = 10,
                },
                widget = wibox.container.background,
                bg = background,
            },
            widget = wibox.container.margin,
            bottom = 4,
          },
          id = 'background_role',
          widget = wibox.container.background
       }
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.focused,
        layout = {
           spacing_widget = {
              thickness = 1,
              color = "#ff0000",
              widget = wibox.widget.separator,
           },
           spacing = 1,
           layout = wibox.layout.fixed.horizontal,
        }
    }

    -- Create the wibox
    if (s.index == 1) then
        s.mywibox = awful.wibar {
            position = "top",
            height = 50,
            screen = s,
            bg = "#00000000"
        }
    else
        s.mywibox = awful.wibar {
            position = "bottom",
            height = 50,
            screen = s,
            bg = "#00000000"
        }

    end

    if (s.index == 1) then
       -- Add widgets to the wibox
       s.mywibox:setup {
          widget = wibox.container.margin,
          margins = 10,
          {
             widget = wibox.container.background,
             bg = background,
             {
                layout = wibox.layout.align.horizontal,
                {
                   layout = wibox.layout.fixed.horizontal,
                   s.mytaglist,
                   { -- empty textbox instead of spacing widget
                      widget = wibox.widget.textbox,
                      text = "  "
                   }
                },
                s.mytasklist,
                {
                   layout = wibox.layout.fixed.horizontal,

                   -- Updates
                   {
                      widget = wibox.container.background,
                      bg = violet,
                      fg = background,
                      {
                         widget = awful.widget.watch('checkupdates', 3600, function (widget, out)
                                                        local updateCount = 0
                                                        for str in string.gmatch(out, "\n") do
                                                           updateCount = updateCount + 1
                                                        end

                                                        if updateCount > 0 then
                                                           widget:set_text(" Updates: "..tostring(updateCount).." ")
                                                        else
                                                           widget:set_text(" Updates not found ")
                                                        end
                         end),
                      },
                   },
                   -- Memory
                   {
                      widget = wibox.container.background,
                      bg = blue,
                      fg = background,
                      {
                         widget = awful.widget.watch('free -m', 1, function (widget, out)
                                                        local total = string.match(out, "%d+")
                                                        local totalCharNum = string.find(out, "%d+")
                                                        local used = string.match(out, "%d+", totalCharNum + 5)
                                                        widget:set_text(" Memory: "..used.." MB / "..total.." MB ")
                         end),
                      }
                   },

                   {
                      widget = wibox.container.background,
                      bg = majenta,
                      fg = background,
                      {
                         widget = mykeyboardlayout
                      }
                   },
                   wibox.widget.systray(),
                   mytextclock,
                   s.mylayoutbox,
                }
             }
          }
       }
    else
       s.mywibox:setup {
          widget = wibox.container.margin,
          margins = 10,
          {
             widget = wibox.container.background,
             bg = background,
             {
                layout = wibox.layout.align.horizontal,
                {
                   layout = wibox.layout.fixed.horizontal,
                   s.mytaglist,
                   { -- empty textbox instead of spacing widget
                      widget = wibox.widget.textbox,
                      text = "  "
                   }
                },
                s.mytasklist,
                {
                   layout = wibox.layout.fixed.horizontal,
                   wibox.widget.systray(),
                   mytextclock,
                   s.mylayoutbox,
                }
             }
          }
       }
    end
end

-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

keyboardLayout = 'ru'

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({modkey, }, "j",
       function ()
          awful.client.focus.bydirection("down")
       end,
       {description = "focus window below", group = "client"}
    ),

    awful.key({modkey, }, "k",
       function ()
          awful.client.focus.bydirection("up")
       end,
       {description = "focus window above", group = "client"}
    ),

    awful.key({modkey, }, "h",
       function ()
          awful.client.focus.bydirection("left")
       end,
       {description = "focus window left", group = "client"}
    ),

    awful.key({modkey, }, "l",
       function ()
          awful.client.focus.bydirection("right")
       end,
       {description = "focus window right", group = "client"}
    ),

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

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}
    ),

    -- Launcher
    awful.key({ modkey }, "r",
       function ()
          awful.spawn("rofi -show run")
       end,
       {description = "Run rofi", group = "launcher"}
    ),

    -- Custom keybindings
    awful.key({modkey, "Shift"}, "m",
       function ()
          awful.spawn("spotify")
       end,
       {decription = "Run spotify", group = "applications"}
    ),

    -- awful.key({modkey}, "q", "a"
    --    function ()
    --       awful.spawn("alacritty")
    --    end,
    --    {decription = "Run spotify", group = "applications"}
    -- ),

    awful.key({modkey}, "e",
       function ()
          awful.spawn("emacsclient -c --eval '(load-file \"~/.emacs.d/init.el\")'")
       end,
       {decription = "Run emacs daemon", group = "applications"}
    ),

    awful.key({modkey, "Shift"}, "e",
       function ()
          awful.spawn("emacs")
       end,
       {decription = "Run emacs", group = "applications"}
    ),

    awful.key({modkey}, "b",
       function ()
          awful.spawn("firefox")
       end,
       {description = "Run firefox", group = "applications"}
    ),

    -- change keyboard layout
    awful.key({modkey}, "space",
       function ()
          awful.spawn('setxkbmap '..keyboardLayout)
          keyboardLayout = keyboardLayout == 'us' and 'ru' or 'us'
       end,
       {description = "Change layout", group = "applications"}
    ),

    -- pavucontrol
    awful.key({modkey, "Shift"}, "v",
       function ()
          awful.spawn("pavucontrol")
       end,
       {description = "Open pavucontrol", group = "applications"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"}, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" }
      }, properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- autostart
awful.spawn("/home/bot/.config/awesome/autostart.sh")
