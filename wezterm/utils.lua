local M = {}
local wezterm = require('wezterm')

M.is_vim = function(pane) return pane:get_user_vars().IS_NVIM == 'true' end
M.is_tmux = function(pane) return pane:get_user_vars().IS_TMUX == 'true' end
M.is_zellij = function(pane) return pane:get_user_vars().IS_ZELLIJ == 'true' end
M.is_vim_or_tmux_or_zellij = function(pane) return M.is_vim(pane) or M.is_tmux(pane) or M.is_zellij(pane) end

---@class wezterm.key
---@field key string
---@field mods string | nil
---@field action? fun(win, pane): nil

---@param fn fun(win, pane): boolean
---@param opts wezterm.key
M.if_run = function(fn, opts)
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
M.activate_pane = function(opts, direction)
  opts.action = function(win, pane)
    wezterm.background_child_process({ 'zsh', '-ilc',
      'multiplexer activate_pane ' .. direction:lower()
    })
  end
  return M.if_run(function(_, pane)
    return not M.is_vim_or_tmux_or_zellij(pane)
  end, opts)
end

---@param opts wezterm.key
---@param direction "Left" | "Down" | "Up" | "Right"
---@param amount? number
M.adjust_pane = function(opts, direction, amount)
  opts.action = function(win, pane)
    wezterm.background_child_process({ 'zsh', '-ilc',
      'multiplexer resize_pane ' .. direction:lower()
    })
  end
  return M.if_run(function(_, pane)
    return not M.is_vim_or_tmux_or_zellij(pane)
  end, opts)
end


---@param filename string
---@param t table
M.debug_table = function(filename, t)
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

return M
