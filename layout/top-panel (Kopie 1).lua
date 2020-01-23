local awful = require('awful')
local beautiful = require('beautiful')
local wibox = require('wibox')
local TaskList = require('widget.task-list')
local TagList = require('widget.tag-list')
local gears = require('gears')
local clickable_container = require('widget.material.clickable-container')
local mat_icon_button = require('widget.material.icon-button')
local mat_icon = require('widget.material.icon')
local dpi = require('beautiful').xresources.apply_dpi
local icons = require('theme.icons')


----------------------------
--WIDGETS
----------------------------


--HOMEBUTTON
----------------------------
 
  local menu_icon =
    wibox.widget {
    icon = icons.menu,
    size = dpi(24),
    widget = mat_icon
  }

  local home_button =
    wibox.widget {
    wibox.widget {
      menu_icon,
      widget = clickable_container
    },
    bg = beautiful.primary.hue_500,
    widget = wibox.container.background
  }

    home_button:buttons(
    gears.table.join(
      awful.button(
        {},
        1,
        nil,
        function()
          panel:toggle()
        end
      )
    )
  )

  panel:connect_signal(
    'opened',
    function()
      menu_icon.icon = icons.close
    end
  )


  panel:connect_signal(
    'closed',
    function()
      menu_icon.icon = icons.menu
    end
  )


--ADDBUTTON
----------------------------
local add_button = mat_icon_button(mat_icon(icons.plus, dpi(24)))
add_button:buttons(
  gears.table.join(
    awful.button(
      {},
      1,
      nil,
      function()
        awful.spawn(
          awful.screen.focused().selected_tag.defaultApp,
          {
            tag = _G.mouse.screen.selected_tag,
            placement = awful.placement.bottom_right
          }
        )
      end
    )
  )
)


--SYSTRAY
----------------------------
  local systray = wibox.widget.systray()
  systray:set_horizontal(true)
  systray:set_base_size(24)


--CLOCK
----------------------------
local textclock = wibox.widget.textclock('<span font="Roboto Mono bold 11">%H %M</span>')
  -- Clock / Calendar 12AM/PM fornat
  -- local textclock = wibox.widget.textclock('<span font="Roboto Mono bold 11">%I\n%M</span>\n<span font="Roboto Mono bold 9">%p</span>')
  -- textclock.forced_height = 56
local clock_widget = wibox.container.margin(textclock, dpi(13), dpi(13), dpi(8), dpi(8))


--LAYOUTBOX
----------------------------
-- Create an imagebox widget which will contains an icon indicating which layout we're using.
-- We need one layoutbox per screen.
local LayoutBox = function(s)
  local layoutBox = clickable_container(awful.widget.layoutbox(s))
  layoutBox:buttons(
    awful.util.table.join(
      awful.button(
        {},
        1,
        function()
          awful.layout.inc(1)
        end
      ),
      awful.button(
        {},
        3,
        function()
          awful.layout.inc(-1)
        end
      ),
      awful.button(
        {},
        4,
        function()
          awful.layout.inc(1)
        end
      ),
      awful.button(
        {},
        5,
        function()
          awful.layout.inc(-1)
        end
      )
    )
  )
  return layoutBox
end


----------------------------
--PANELSETUP
----------------------------


local TopPanel = function(s)
  local panel =
    wibox(
    {
      ontop = true,
      screen = s,
      height = dpi(48),
      width = s.geometry.width,
      x = s.geometry.x,
      y = s.geometry.y,
      stretch = false,
      bg = beautiful.background.hue_800,
      fg = beautiful.fg_normal,
      struts = {
        top = dpi(48)
      }
    }
  )

  panel:struts(
    {
      top = dpi(48)
    }
  )

  panel:setup {
    layout = wibox.layout.align.horizontal,
    {
      layout = wibox.layout.fixed.horizontal,
      HomeButton,
      TagList(s),
      TaskList(s),
      add_button
    },
    nil,
    {
      layout = wibox.layout.fixed.horizontal,
      wibox.container.margin(systray, dpi(10), dpi(10)),
      require('widget.package-updater'),
      require('widget.wifi'),
      require('widget.battery'),
      clock_widget,
      LayoutBox(s)
    }
  }

  return panel
end

return TopPanel
