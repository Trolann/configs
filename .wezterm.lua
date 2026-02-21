local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- Remote hosts. Set mux = true after running: ./install.sh install-mux <name>
local hosts = {
  { name = 'fatherbird', address = 'fatherbird', user = 'fb', mux = false },
  -- { name = 'workserver', address = '10.0.0.5', user = 'me', mux = true },
}

local is_windows = wezterm.target_triple:find('windows') ~= nil

if is_windows then
  config.unix_domains = {
    { name = 'wsl', serve_command = { 'wsl', 'wezterm-mux-server', '--daemonize' } },
  }
  config.default_gui_startup_args = { 'connect', 'wsl' }
end

local ssh_domains = {}
for _, host in ipairs(hosts) do
  table.insert(ssh_domains, {
    name           = host.name,
    remote_address = host.address,
    username       = host.user,
    multiplexing   = host.mux and 'WezTerm' or 'None',
    assume_shell   = 'Posix',
  })
end
config.ssh_domains = ssh_domains

config.font = wezterm.font 'JetBrains Mono'
config.wsl_domains = wezterm.default_wsl_domains()

config.keys = {
    {
        key = 'Enter',
        mods = 'SHIFT',
        action = wezterm.action.SendString('\x1b[13;2u'),
    },
    {
        key = [[\]],
        mods = "CTRL|ALT",
        action = wezterm.action({
            SplitHorizontal = { domain = "CurrentPaneDomain" },
        }),
    },
    {
        key = [[\]],
        mods = "CTRL",
        action = wezterm.action({
            SplitVertical = { domain = "CurrentPaneDomain" },
        }),
    },
    {
        key = "q",
        mods = "CTRL",
        action = wezterm.action({ CloseCurrentPane = { confirm = false } }),
    },
    {
        key = "h",
        mods = "CTRL|SHIFT",
        action = wezterm.action({ ActivatePaneDirection = "Left" }),
    },
    {
        key = "l",
        mods = "CTRL|SHIFT",
        action = wezterm.action({ ActivatePaneDirection = "Right" }),
    },
    {
        key = "k",
        mods = "CTRL|SHIFT",
        action = wezterm.action({ ActivatePaneDirection = "Up" }),
    },
    {
        key = "j",
        mods = "CTRL|SHIFT",
        action = wezterm.action({ ActivatePaneDirection = "Down" }),
    },
    {
        key = "h",
        mods = "CTRL|SHIFT|ALT",
        action = wezterm.action({ AdjustPaneSize = { "Left", 1 } }),
    },
    {
        key = "l",
        mods = "CTRL|SHIFT|ALT",
        action = wezterm.action({ AdjustPaneSize = { "Right", 1 } }),
    },
    {
        key = "k",
        mods = "CTRL|SHIFT|ALT",
        action = wezterm.action({ AdjustPaneSize = { "Up", 1 } }),
    },
    {
        key = "j",
        mods = "CTRL|SHIFT|ALT",
        action = wezterm.action({ AdjustPaneSize = { "Down", 1 } }),
    },
    {
        key = "t",
        mods = "CTRL",
        action = wezterm.action({ SpawnTab = "CurrentPaneDomain" }),
    },
    {
        key = "w",
        mods = "CTRL",
        action = wezterm.action({ CloseCurrentTab = { confirm = false } }),
    },
    {
        key = "Tab",
        mods = "CTRL",
        action = wezterm.action({ ActivateTabRelative = 1 }),
    },
    {
        key = "Tab",
        mods = "CTRL|SHIFT",
        action = wezterm.action({ ActivateTabRelative = -1 }),
    },
    {
        key = "x",
        mods = "CTRL",
        action = "ActivateCopyMode",
    },
    {
        key = "v",
        mods = "CTRL|SHIFT",
        action = wezterm.action({ PasteFrom = "Clipboard" }),
    },
    {
        key = "c",
        mods = "CTRL|SHIFT",
        action = wezterm.action({ CopyTo = "ClipboardAndPrimarySelection" }),
    },
}

-- Padding
config.window_padding = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
}

-- Tab Bar
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.show_tab_index_in_tab_bar = false
config.tab_bar_at_bottom = true

-- General
config.automatically_reload_config = true
config.inactive_pane_hsb = { saturation = 1.0, brightness = 1.0 }
config.window_background_opacity = 1.0
config.window_close_confirmation = "NeverPrompt"

return config
