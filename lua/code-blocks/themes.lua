local M = {}

M.themes = {
  catppuccin_mocha = {
    background = '#1e1e2e',
    foreground = '#cdd6f4',
    language = '#89b4fa',
  },
  catppuccin_latte = {
    background = '#eff1f5',
    foreground = '#4c4f69',
    language = '#1e66f5',
  },
  nord = {
    background = '#2e3440',
    foreground = '#d8dee9',
    language = '#88c0d0',
  },
  dracula = {
    background = '#282a36',
    foreground = '#f8f8f2',
    language = '#bd93f9',
  },
  tokyonight_night = {
    background = '#1a1b26',
    foreground = '#c0caf5',
    language = '#7aa2f7',
  },
  tokyonight_day = {
    background = '#e1e2e7',
    foreground = '#3760bf',
    language = '#2959aa',
  },
  gruvbox_dark = {
    background = '#282828',
    foreground = '#ebdbb2',
    language = '#fe8019',
  },
  gruvbox_light = {
    background = '#fbf1c7',
    foreground = '#3c3836',
    language = '#af3a03',
  },
  onedark = {
    background = '#282c34',
    foreground = '#abb2bf',
    language = '#61afef',
  },
  solarized_dark = {
    background = '#002b36',
    foreground = '#839496',
    language = '#268bd2',
  },
  solarized_light = {
    background = '#fdf6e3',
    foreground = '#657b83',
    language = '#268bd2',
  },
  kanagawa = {
    background = '#1f1f28',
    foreground = '#dcd7ba',
    language = '#7e9cd8',
  },
  rose_pine = {
    background = '#191724',
    foreground = '#e0def4',
    language = '#c4a7e7',
  },
  rose_pine_dawn = {
    background = '#faf4ed',
    foreground = '#575279',
    language = '#907aa9',
  },
  github_dark = {
    background = '#0d1117',
    foreground = '#c9d1d9',
    language = '#58a6ff',
  },
  github_light = {
    background = '#ffffff',
    foreground = '#24292e',
    language = '#0366d6',
  },
}

function M.get_theme(name)
  return M.themes[name]
end

function M.list_themes()
  local theme_names = {}

  for name, _ in pairs(M.themes) do
    table.insert(theme_names, name)
  end

  table.sort(theme_names)

  return theme_names
end

function M.has_theme(name)
  return M.themes[name] ~= nil
end

return M
