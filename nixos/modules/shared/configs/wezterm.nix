{
  enable = true;

  extraConfig = ''
    -----------
    -- Utils --
    -----------
    local utils = {}

    utils.is_vim = function(pane) return pane:get_user_vars().IS_NVIM == 'true' end
    utils.is_tmux = function(pane) return pane:get_user_vars().IS_TMUX == 'true' end
    utils.is_zellij = function(pane) return pane:get_user_vars().IS_ZELLIJ == 'true' end
    utils.is_vim_or_tmux_or_zellij = function(pane) return utils.is_vim(pane) or utils.is_tmux(pane) or utils.is_zellij(pane) end

    ---@class wezterm.key
    ---@field key string
    ---@field mods string | nil
    ---@field action? fun(win, pane): nil

    ---@param fn fun(win, pane): boolean
    ---@param opts wezterm.key
    utils.if_run = function(fn, opts)
      local action = opts.action or function() end
      opts.action = wezterm.action_callback(function(win, pane)
        if fn(win, pane) then
          action(win, pane)
        else
          win:perform_action({ SendKey = { key = opts.key, mods = opts.mods } }, pane)
        end
      end)
      return opts
    end

    ---@param opts wezterm.key
    ---@param direction "Left" | "Down" | "Up" | "Right"
    utils.activate_pane = function(opts, direction)
      opts.action = function(win, pane)
        wezterm.background_child_process({ 'env', '__NO_AUTO_FISH=1', 'bash', '-ilc',
          'multiplexer activate_pane ' .. direction:lower()
        })
      end
      return utils.if_run(function(_, pane)
        return not utils.is_vim_or_tmux_or_zellij(pane)
      end, opts)
    end

    ---@param opts wezterm.key
    ---@param direction "Left" | "Down" | "Up" | "Right"
    ---@param amount? number
    utils.adjust_pane = function(opts, direction, amount)
      opts.action = function(win, pane)
        wezterm.background_child_process({ 'env', '__NO_AUTO_FISH=1', 'bash', '-ilc',
          'multiplexer resize_pane ' .. direction:lower()
        })
      end
      return utils.if_run(function(_, pane)
        return not utils.is_vim_or_tmux_or_zellij(pane)
      end, opts)
    end


    ---@param filename string
    ---@param t table
    utils.debug_table = function(filename, t)
      local dump
      dump = function(o)
        if type(o) == 'table' then
          local s = '{ '
          for k, v in pairs(o) do
            if type(k) ~= 'number' then k = '"' .. k .. '"' end
            s = s .. '[' .. k .. '] = ' .. dump(v) .. ','
          end
          return s .. '} '
        else
          return tostring(o)
        end
      end

      local f = io.open(filename, 'w+')
      if not f then
        return
      end

      f:write(dump(t))
      f:flush()
      f:close()
    end

    -----------
    -- Config --
    -----------
    local act = wezterm.action
    local config = wezterm.config_builder()

    config.color_scheme = 'Nord (Gogh)'
    config.window_background_opacity = 0.9
    config.macos_window_background_blur = 5

    config.font_size = 12
    config.line_height = 1.2
    config.font = wezterm.font({
      family = 'Monaspace Argon',
      weight = 'Regular',
      stretch = 'Normal',
      style = 'Normal',
      harfbuzz_features = { 'calt', 'dlig', 'ss01', 'ss02', 'ss03', 'ss04', 'ss05', 'ss06', 'ss07' },
    })
    config.foreground_text_hsb = {
      hue = 1.0,
      saturation = 1.0,
      brightness = 1.4,
    }

    config.default_cursor_style = 'SteadyBar'
    -- config.window_close_confirmation = 'NeverPrompt'

    config.hide_tab_bar_if_only_one_tab = true
    config.use_fancy_tab_bar = false
    config.tab_bar_at_bottom = true
    config.prefer_to_spawn_tabs = true

    config.scrollback_lines = 100000

    config.window_padding = {
      left = 25,
      right = 25,
      top = 25,
      bottom = 0
    }
    config.window_decorations = 'RESIZE'

    config.set_environment_variables = {
      MULTIPLEXER_LIST = 'wezterm,i3'
    }

    config.keys = {
      { key = 't',          mods = 'CMD',       action = act.SpawnCommandInNewTab({ domain = 'CurrentPaneDomain' }) },
      { key = 't',          mods = 'CMD|SHIFT', action = act.SpawnCommandInNewTab({ domain = { DomainName = 'local' }, cwd = wezterm.home_dir }) },
      { key = 'j',          mods = 'CMD',       action = act.SplitPane({ direction = 'Down', command = { domain = 'CurrentPaneDomain' } }) },
      { key = 'j',          mods = 'CMD|SHIFT', action = act.SplitPane({ direction = 'Down', command = { cwd = wezterm.home_dir } }) },
      { key = 'l',          mods = 'CMD',       action = act.SplitPane({ direction = 'Right', command = { domain = 'CurrentPaneDomain' } }) },
      { key = 'l',          mods = 'CMD|SHIFT', action = act.SplitPane({ direction = 'Right', command = { cwd = wezterm.home_dir } }) },
      { key = 'LeftArrow',  mods = 'CMD',       action = act.ActivateTabRelative(-1) },
      { key = 'RightArrow', mods = 'CMD',       action = act.ActivateTabRelative(1) },
      { key = '[',          mods = 'CMD',       action = act.MoveTabRelative(-1) },
      { key = ']',          mods = 'CMD',       action = act.MoveTabRelative(1) },
      { key = 'p',          mods = 'CMD',       action = act.PaneSelect({ mode = 'SwapWithActiveKeepFocus' }) },
      { key = 'p',          mods = 'CMD|SHIFT', action = act.PaneSelect },
      { key = 'e',          mods = 'CMD',       action = act.CloseCurrentPane({ confirm = true }) },
      { key = 'w',          mods = 'CMD',       action = act.CloseCurrentTab({ confirm = true }) },
      utils.activate_pane({ key = 'h', mods = 'CTRL' }, 'Left'),
      utils.activate_pane({ key = 'j', mods = 'CTRL' }, 'Down'),
      utils.activate_pane({ key = 'k', mods = 'CTRL' }, 'Up'),
      utils.activate_pane({ key = 'l', mods = 'CTRL' }, 'Right'),
      utils.adjust_pane({ key = 'h', mods = 'CTRL|SHIFT' }, 'Left'),
      utils.adjust_pane({ key = 'j', mods = 'CTRL|SHIFT' }, 'Down'),
      utils.adjust_pane({ key = 'k', mods = 'CTRL|SHIFT' }, 'Up'),
      utils.adjust_pane({ key = 'l', mods = 'CTRL|SHIFT' }, 'Right'),
      utils.if_run(function(_, pane) return not utils.is_vim_or_tmux_or_zellij(pane) end, {
        key = 'g',
        mods = 'CMD',
        action = function(win, pane)
          win:perform_action({ EmitEvent = 'trigger-vim-with-scrollback' }, pane)
        end
      })
      -- switch pane?
      -- { key = '[',          mods = 'CTRL|SHIFT', action = act.RotatePanes('CounterClockwise') },
      -- { key = ']',          mods = 'CTRL|SHIFT', action = act.RotatePanes('Clockwise') }
    }

    wezterm.on('trigger-vim-with-scrollback', function(window, pane)
      local name = os.tmpname()
      local f = io.open(name, 'w+')
      if not f then
        return
      end

      local text = pane:get_lines_as_escapes(pane:get_dimensions().scrollback_rows)

      f:write(text)
      f:flush()
      f:close()

      local mux_window = window:mux_window()
      local tabs = mux_window:tabs_with_info()
      local current_index = 0
      for _, tab_info in ipairs(tabs) do
        if tab_info.is_active then
          current_index = tab_info.index
          break
        end
      end

      mux_window:spawn_tab({
        args = { 'nvim', name, [[+lua require('utils').colorize()]] },
      })
      window:perform_action(act.MoveTab(current_index + 1), pane)

      wezterm.sleep_ms(1000)
      os.remove(name)
    end)

    return config
  '';
}
