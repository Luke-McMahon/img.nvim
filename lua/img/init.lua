local M = {}

local defaults = {
  extensions = { 'png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp', 'svg', 'ico', 'tiff', 'tif' },
}

M.config = vim.deepcopy(defaults)

--- Check if a filename has an image extension
---@param filename string
---@return boolean
function M.is_image(filename)
  if not filename then
    return false
  end
  local ext = filename:match('%.([^%.]+)$')
  if not ext then
    return false
  end
  ext = ext:lower()
  for _, image_ext in ipairs(M.config.extensions) do
    if ext == image_ext then
      return true
    end
  end
  return false
end

--- Open a file in the default system viewer
---@param path string
---@return boolean success
function M.open(path)
  if not path then
    return false
  end
  local ok = pcall(vim.ui.open, path)
  return ok
end

--- Open the containing directory of a path
---@param path string
---@return boolean success
function M.open_directory(path)
  if not path then
    return false
  end
  local dir = vim.fn.fnamemodify(path, ':h')
  local ok = pcall(vim.ui.open, dir)
  return ok
end

--- Handle <CR> in oil buffer - open image or pass through
function M._oil_enter()
  local ok, oil = pcall(require, 'oil')
  if not ok then
    return
  end

  local entry = oil.get_cursor_entry()
  local filename = entry and entry.name
  local dir = oil.get_current_dir()

  -- Pass through to oil for non-images or missing data
  if not filename or not dir or not M.is_image(filename) then
    oil.select()
    return
  end

  -- Ensure dir has trailing slash for path concatenation
  if not dir:match('/$') then
    dir = dir .. '/'
  end

  local full_path = dir .. filename

  if not M.open(full_path) then
    M.open_directory(full_path)
  end
end

--- Set up oil.nvim integration via FileType autocmd
function M._setup_oil()
  local group = vim.api.nvim_create_augroup('ImgNvim', { clear = true })
  vim.api.nvim_create_autocmd('FileType', {
    group = group,
    pattern = 'oil',
    callback = function(args)
      vim.keymap.set('n', '<CR>', M._oil_enter, {
        buffer = args.buf,
        noremap = true,
        silent = true,
        desc = 'Open image or select entry',
      })
    end,
  })
end

--- Setup the plugin
---@param opts? table
function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', defaults, opts or {})

  vim.api.nvim_create_user_command('ImgOpen', function()
    local ok, oil = pcall(require, 'oil')
    if not ok then
      return
    end
    local ok_util, oil_util = pcall(require, 'oil.util')
    if ok_util and oil_util.is_oil_bufnr(0) then
      M._oil_enter()
    end
  end, { desc = 'Open image under cursor in default viewer' })

  M._setup_oil()
end

return M
