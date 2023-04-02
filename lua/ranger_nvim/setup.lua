
local M = {}

local _config = {}

local function set_fileopener(config)
  local valid_fileopener = {'rifle', 'xdg-open', 'nvim'}
  local default_fileopener = 'rifle'

  if config.fileopener then
      -- Check if fileopener is valid

      for _, v in ipairs(valid_fileopener) do
          if config.fileopener == v then
              return config.fileopener
          end
      end

      error('Invalid fileopener: ' .. config.fileopener)

  end

  return default_fileopener

end

function M.setup(config)
  _config.fileopener = set_fileopener(config)
  _config.mapping = config.mapping or '<leader>f'


  return _config
end

-- run setup from nvim


return M





