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

-- Wallpaper changing every hour
gears.timer {
   timeout = 1800,
   callback = function ()
      awful.spawn.with_shell("sh ~/Wallpapers/imageSetter.sh")
   end
}:start()

-- {{{ Error handling
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
    -- lain.layout.uselesstile,
    -- awful.layout.suit.tile.left,
    -- awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()
mytextclock.format = " %I:%M:%S %p "
mytextclock.refresh = 1
mytextclock.timezone = "+03:00"

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
                   -- TODO: change texbox to icon
                   {
                      {
                         image = os.getenv ("HOME") .. "/.config/awesome/icons/feather_48px/sidebar.svg",
                         forced_width = 30,
                         forced_height = 30,
                         buttons = {
                            awful.button ({}, 1, nil, function () systemInfo.visible = not systemInfo.visible end)
                         },
                         widget = wibox.widget.imagebox,
                      },
                      right = 5,
                      widget = wibox.container.margin
                   },
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


local keys = require "keys"
globalkeys = keys.keys
clientkeys = keys.clientkeys

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

client.connect_signal("property::minimized", function(c)
     c.minimized = false
 end)
 client.connect_signal("property::maximized", function(c)
     c.maximized = false
 end)

-- autostart
awful.spawn("/home/botnikos/.config/awesome/autostart.sh")
