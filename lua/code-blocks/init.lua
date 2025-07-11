local M = {}

local namespace_id = vim.api.nvim_create_namespace('code_blocks')
local themes = require('code-blocks.themes')
local MARKER = '```'
local code_blocks = {}
local config = {
  theme = nil,
  language_color = nil,
  use_treesitter = true,
  hide_markers = false,
}


function M.setup(opts)
  config = vim.tbl_deep_extend('force', config, opts or {})
  if config.theme then
    if not themes.has_theme(config.theme) then
      vim.notify('code-blocks: unknown theme "' .. config.theme .. '"', vim.log.levels.WARN)
      config.theme = nil
    end
  end

  M.create_highlights()
  M.setup_autocmds()
  M.create_commands()
end

function M.create_highlights()
  local theme_colors = nil

  if config.theme then
    theme_colors = themes.get_theme(config.theme)
  end

  if theme_colors then
    local attributes = {}
    if theme_colors.background then
      table.insert(attributes, 'guibg=' .. theme_colors.background)
    end

    if theme_colors.foreground then
      table.insert(attributes, 'guifg=' .. theme_colors.foreground)
    end

    if #attributes > 0 then
      vim.cmd('highlight CodeBlock ' .. table.concat(attributes, ' '))
    end
  end

  local lang_color = config.language_color or (theme_colors and theme_colors.language)
  if lang_color then
    vim.cmd(string.format('highlight CodeBlockLang guifg=%s', lang_color))
  end
end

function M.find_code_blocks(curbuf)
  curbuf = curbuf or vim.api.nvim_get_current_buf()
  local lines = vim.api.nvim_buf_get_lines(curbuf, 0, -1, false)
  local blocks = {}
  local start_line = nil

  for i, line in ipairs(lines) do
    if line:sub(1, 3) == MARKER then
      if not start_line then
        start_line = i
      else
        local lang = lines[start_line]:match("^```(%w+)")
        table.insert(blocks, {
          start = start_line - 1,
          end_line = i - 1,
          lang = lang
        })
        start_line = nil
      end
    end
  end

  return blocks
end

function M.apply_treesitter(curbuf, block)
  if not config.use_treesitter or not block.lang then
    return
  end

  local ok, has_parser = pcall(vim.treesitter.language.add, block.lang)
  if not ok or not has_parser then
    return
  end

  local start_line = block.start + 1
  local end_line = block.end_line - 1

  if start_line > end_line then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(curbuf, start_line, end_line + 1, false)
  local code = table.concat(lines, '\n')
  local parser = vim.treesitter.get_string_parser(code, block.lang)

  local tree = parser:parse()[1]
  if not tree then
    return
  end

  local query = vim.treesitter.query.get(block.lang, 'highlights')
  if not query then
    return
  end

  for id, node in query:iter_captures(tree:root(), code, 0, -1) do
    local name = query.captures[id]
    local start_row, start_col, end_row, end_col = node:range()

    vim.api.nvim_buf_set_extmark(curbuf, namespace_id, start_line + start_row, start_col, {
      end_row = start_line + end_row,
      end_col = end_col,
      hl_group = '@' .. name,
      priority = 100,
    })
  end
end

function M.highlight_language(curbuf, block)
  if not block.lang then
    return
  end

  local theme_colors = config.theme and themes.get_theme(config.theme)
  local has_lang_color = config.language_color or (theme_colors and theme_colors.language)

  if not has_lang_color then
    return
  end

  local start_col = 3
  local end_col = start_col + #block.lang

  vim.api.nvim_buf_set_extmark(curbuf, namespace_id, block.start, start_col, {
    end_col = end_col,
    hl_group = 'CodeBlockLang',
    priority = 150,
  })
end

function M.hide_markers(curbuf, block)
  local start_line = vim.api.nvim_buf_get_lines(curbuf, block.start, block.start + 1, false)[1] or ''
  local end_line = vim.api.nvim_buf_get_lines(curbuf, block.end_line, block.end_line + 1, false)[1] or ''

  vim.api.nvim_buf_set_extmark(curbuf, namespace_id, block.start, 0, {
    virt_text = {{string.rep(' ', #start_line), 'Normal'}},
    virt_text_pos = 'overlay',
    priority = 300,
  })

  vim.api.nvim_buf_set_extmark(curbuf, namespace_id, block.end_line, 0, {
    virt_text = {{string.rep(' ', #end_line), 'Normal'}},
    virt_text_pos = 'overlay',
    priority = 300,
  })
end

function M.apply_background(curbuf, block)
  local theme_colors = config.theme and themes.get_theme(config.theme)
  if not theme_colors or not theme_colors.background then
    return
  end

  local start_content = block.start + 1
  local end_content = block.end_line - 1

  if start_content <= end_content then
    for line = start_content, end_content do
      vim.api.nvim_buf_set_extmark(curbuf, namespace_id, line, 0, {
        end_line = line + 1,
        end_col = 0,
        hl_group = 'CodeBlock',
        hl_eol = true,
        priority = 10,
      })
    end
  end
end

function M.highlight_blocks(curbuf)
  curbuf = curbuf or vim.api.nvim_get_current_buf()

  vim.api.nvim_buf_clear_namespace(curbuf, namespace_id, 0, -1)

  local blocks = M.find_code_blocks(curbuf)
  code_blocks[curbuf] = blocks

  for _, block in ipairs(blocks) do
    M.apply_background(curbuf, block)

    if not config.hide_markers then
      M.highlight_language(curbuf, block)
    end

    if config.hide_markers then
      M.hide_markers(curbuf, block)
    end

    if config.use_treesitter then
      vim.schedule(function()
        M.apply_treesitter(curbuf, block)
      end)
    end
  end
end

function M.toggle_code_block()
  local curbuf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1

  local blocks = code_blocks[curbuf] or M.find_code_blocks(curbuf)

  for _, block in ipairs(blocks) do
    if line >= block.start and line <= block.end_line then
      vim.api.nvim_buf_set_lines(curbuf, block.end_line, block.end_line + 1, false, {})
      vim.api.nvim_buf_set_lines(curbuf, block.start, block.start + 1, false, {})
      M.highlight_blocks(curbuf)
      return
    end
  end

  local current_line = vim.api.nvim_buf_get_lines(curbuf, line, line + 1, false)[1] or ''
  vim.api.nvim_buf_set_lines(curbuf, line, line + 1, false, {
    MARKER,
    current_line,
    MARKER
  })

  vim.api.nvim_win_set_cursor(0, {line + 2, 0})

  M.highlight_blocks(curbuf)
end

function M.create_code_block(lang)
  local curbuf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1

  vim.api.nvim_buf_set_lines(curbuf, line, line, false, {
    MARKER .. (lang or ''),
    '',
    MARKER
  })

  vim.api.nvim_win_set_cursor(0, {line + 2, 0})

  M.highlight_blocks(curbuf)
end

function M.setup_autocmds()
  local group = vim.api.nvim_create_augroup('CodeBlocks', { clear = true })

  vim.api.nvim_create_autocmd({'TextChanged', 'TextChangedI', 'BufEnter', 'BufWinEnter'}, {
    group = group,
    callback = function(args)
      M.highlight_blocks(args.buf)
    end,
  })
end

function M.create_commands()
  vim.api.nvim_create_user_command('CodeBlockToggle', function()
    M.toggle_code_block()
  end, {})

  vim.api.nvim_create_user_command('CodeBlockCreate', function(opts)
    M.create_code_block(opts.args)
  end, { nargs = '?' })

  vim.api.nvim_create_user_command('CodeBlockThemes', function(opts)
    if opts.args == '' then
      local theme_list = themes.list_themes()
      vim.notify('available themes:\n' .. table.concat(theme_list, '\n'))
    else
      local theme_name = opts.args
      if themes.has_theme(theme_name) then
        config.theme = theme_name
        M.create_highlights()
        M.highlight_blocks()
      else
        vim.notify('unknown theme: ' .. theme_name, vim.log.levels.ERROR)
      end
    end
  end, {
    nargs = '?',
    complete = function(partial)
      local theme_list = themes.list_themes()
      return vim.tbl_filter(function(theme)
        return theme:find('^' .. partial)
      end, theme_list)
    end,
  })

  vim.api.nvim_create_user_command('CodeBlockMarkersToggle', function()
    config.hide_markers = not config.hide_markers
    M.highlight_blocks()
  end, {})
end

function M.get_block_at_cursor()
  local curbuf = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1

  local blocks = code_blocks[curbuf] or M.find_code_blocks(curbuf)
  for _, block in ipairs(blocks) do
    if line >= block.start and line <= block.end_line then
      return block
    end
  end

  return nil
end

return M
