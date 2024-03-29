local s = require('ranger_nvim.setup')

local M = {}

local data = {
    tmp_path = '/tmp/ranger_nvim_tmp',
    log_path = '/tmp/ranger_nvim.log',
    buf = nil,
    win = nil,
    debug = false,
    config = {}
}




local function create_window()
    local buf = vim.api.nvim_create_buf(true, true) -- create new emtpy buffer

    -- get dimensions
    local width = vim.api.nvim_get_option("columns")
    local height = vim.api.nvim_get_option("lines")
    -- calculate our floating window size
    -- local win_height = math.ceil(height * 0.8 - 4)
    -- local win_width = math.ceil(width * 0.8)
    local win_height = height
    local win_width = width
    -- Starting position
    -- local row = math.ceil((height - win_height) / 2 - 1)
    -- local col = math.ceil((width - win_width) / 2)
    local row = 0
    local col = 0

    -- set some options
    local opts = {
        style = "minimal",
        relative = "editor",
        width = win_width,
        height = win_height,
        row = row,
        col = col,
    }
    local win = vim.api.nvim_open_win(buf, true, opts)
    vim.api.nvim_call_function('nvim_win_set_option', {win, 'winhl', 'Normal:ErrorFloat'})
    vim.api.nvim_win_set_option(win, 'winhighlight', 'Normal:Normal') -- set win bg color
    vim.api.nvim_win_close(win, true) -- remove window overlay
    vim.cmd('buffer ' .. buf) -- swith to buffer

    data.buf = buf
    data.win = win

end

local function open_ranger(dir)
    if data.debug == true then os.execute('echo "$(date +%T):Start:open_ranger()" >> ranger_nvim.log') end

    if io.open(data.tmp_path) ~= nil then
        os.execute('rm ' .. data.tmp_path)
    end

    if dir == nil then
        vim.api.nvim_command('terminal ranger --choosefile ' .. data.tmp_path)
    else
        vim.api.nvim_command('terminal ranger --choosefile ' .. data.tmp_path .. ' ' .. dir)
    end
end

local function read_ranger_tmp()
    local tmp_file=io.open(data.tmp_path)

    if tmp_file == nil then
        return nil
    end

    local open_path = tmp_file:read('*l')
    io.close(tmp_file)
    return open_path
end

local function open_with_nvim(open_path)
    vim.cmd('edit ' .. open_path)
    vim.cmd('filetype detect')
end




-- TODO: Refactor X open fuction if ok
-- TODO: remember last ranger item pos
local function open_with_rifle(open_path)
    os.execute('rifle ' .. open_path)
    local dir = string.gsub(open_path, "(.*/)(.*)", "%1")
    create_window()
    open_ranger(dir)
    vim.api.nvim_feedkeys("i", "m", false)
end

local function open_with_xdg(open_path)
    os.execute('xdg-open ' .. open_path .. ' &')

    local dir = string.gsub(open_path, "(.*/)(.*)", "%1")
    create_window()
    open_ranger(dir)
    vim.api.nvim_feedkeys("i", "m", false)
end

local function open_with_other(open_path)
    if data.config.fileopener == 'rifle' then
        open_with_rifle(open_path)
    elseif data.config.fileopener == 'xdg-open' then
        open_with_xdg(open_path)
    end
    -- elseif data.config.fileopener == 'nvim' then
    --     open_with_nvim(open_path)
    -- end
end


local function check_default_program(open_path)
    -- Check if text editor is default program

    local grep_opts = '-e nvim -e vim -e nano -e micro -e vi -e EDITOR' -- Open terminal editors in nvim

    local default_nvim = nil

     if data.config.fileopener == 'rifle' then
        default_nvim = io.popen('rifle -l ' .. open_path .. '| head -n 1 | grep ' .. grep_opts)-- .. grep_opts)
         return #default_nvim:read("*a")

     elseif data.config.fileopener == 'xdg-open' then
         default_nvim = io.popen('xdg-mime query default $(xdg-mime query filetype ' .. open_path .. ') | grep ' .. grep_opts)
         return #default_nvim:read("*a")

     elseif data.config.fileopener == 'nvim' then
         return 1
     end

     -- TODO: how to read result from io.popen. Only gets 'userdata'


end

local function open_default_program()
    if data.debug == true then os.execute('echo "$(date +%T):Start:open_default_program()" >> ranger_nvim.log') end

    vim.api.nvim_buf_delete(data.buf, {})
    local open_path = read_ranger_tmp()              -- Get selected ranger file path
    if open_path == nil then
        return                                       -- Exit if tmp does not exist
    end

    local len_string = check_default_program(open_path)

    if (len_string > 0) then
        if data.debug == true then os.execute('echo "$(date +%T):if string>0:open_with_nvim()" >> ' .. data.log_path) end
        open_with_nvim(open_path)
    else
        if data.debug == true then os.execute('echo "$(date +%T):else:open_with_rifle" >> ' .. data.log_path) end
        open_with_other(open_path)
    end

    if data.debug == true then os.execute('echo "$(date +%T):End:open_default_program()" >> ' .. data.log_path) end
end

local function set_auto_cmd()
    vim.api.nvim_create_autocmd({"TermOpen"}, {
        pattern = {"term://*ranger*"},
        command = "startinsert"
    })
    -- Deletes terminal buffer and opens path in default rifle application
    vim.api.nvim_create_autocmd({"TermClose"}, {
        pattern = {"term://*ranger*"},
        callback = open_default_program
    })
end

function M.ranger_nvim()
    create_window()
    open_ranger()
end


function M.setup(config)
    set_auto_cmd()

    -- Get config
    data.config = s.setup(config)

    -- Print config in log
    if data.debug == true then 
        os.execute('echo "$(date +%T):Print data.config: key | value:" >> ' .. data.log_path)
        for k, v in pairs(data.config) do
            os.execute('echo "     ' .. k .. ' | ' .. v .. '" >> ' .. data.log_path)
        end
    end

    -- set keymap
    vim.keymap.set('n', data.config.mapping, '<cmd>lua require("ranger_nvim").ranger_nvim()<CR>')

    -- XXX: create user command

end


return M

