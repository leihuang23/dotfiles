local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

config.color_scheme = "rose-pine-moon"
config.font = wezterm.font("Hack Nerd Font")
config.font_size = 15.0
config.window_background_opacity = 0.8
config.macos_window_background_blur = 50
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

-- rose-pine-moon ships with selection_bg equal to the background, so
-- selections are invisible. Use high-contrast gold on base for an obvious highlight.
config.colors = {
  selection_fg = "#232136",
  selection_bg = "#f6c177",
}

-- Brief in-window tip on the tab bar (no system notifications).
local function show_copied_tip(window)
  wezterm.GLOBAL.copy_tip_token = (wezterm.GLOBAL.copy_tip_token or 0) + 1
  local token = wezterm.GLOBAL.copy_tip_token

  local overrides = window:get_config_overrides() or {}
  overrides.hide_tab_bar_if_only_one_tab = false
  window:set_config_overrides(overrides)

  window:set_right_status(wezterm.format({
    { Foreground = { Color = "#e0def4" } },
    { Background = { Color = "#3e8fb0" } },
    { Attribute = { Intensity = "Bold" } },
    { Text = "  Copied to clipboard  " },
  }))

  wezterm.time.call_after(1.5, function()
    if wezterm.GLOBAL.copy_tip_token ~= token then
      return
    end
    pcall(function()
      window:set_right_status("")
      local o = window:get_config_overrides() or {}
      o.hide_tab_bar_if_only_one_tab = nil
      window:set_config_overrides(o)
    end)
  end)
end

-- Copy on mouse-up, clear the highlight, show a short tip.
-- Empty clicks still open hyperlinks.
local function copy_selection_with_tip(destination)
  return wezterm.action_callback(function(window, pane)
    local selection = window:get_selection_text_for_pane(pane)
    if selection == nil or selection == "" then
      window:perform_action(
        act.CompleteSelectionOrOpenLinkAtMouseCursor(destination),
        pane
      )
      return
    end

    window:perform_action(act.CopyTo(destination), pane)
    window:perform_action(act.ClearSelection, pane)
    show_copied_tip(window)
  end)
end

local clipboard = "ClipboardAndPrimarySelection"

config.mouse_bindings = {
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "NONE",
    action = copy_selection_with_tip(clipboard),
  },
  {
    event = { Up = { streak = 1, button = "Left" } },
    mods = "SHIFT",
    action = copy_selection_with_tip(clipboard),
  },
  {
    event = { Up = { streak = 2, button = "Left" } },
    mods = "NONE",
    action = copy_selection_with_tip(clipboard),
  },
  {
    event = { Up = { streak = 3, button = "Left" } },
    mods = "NONE",
    action = copy_selection_with_tip(clipboard),
  },
}

return config
