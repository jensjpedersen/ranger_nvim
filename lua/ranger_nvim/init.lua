
local data = {
    tmp_path = '/tmp/ranger_nvim_tmp',
    buf = nil,
    win = nil
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
        col = col
    }
    local win = vim.api.nvim_open_win(buf, true, opts)
    vim.api.nvim_call_function('nvim_win_set_option', {win, 'winhl', 'Normal:ErrorFloat'})
    data.buf = buf
    data.win = win
end

local function open_ranger(dir)
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


local function open_default_program()
    vim.api.nvim_buf_delete(data.buf, {})
    local open_path = read_ranger_tmp()              -- Get selected ranger file path
    if open_path == nil then
        return                                       -- Exit if tmp does not exist
    end

    -- Timout and default to nvim if rifle command takes to long
    local status = io.popen('timeout 0.5 rifle -l ' .. open_path .. ' &> /dev/null; echo $?')
    local status = status:read('*n')

    local grep_opts = '-e nvim -e vim -e nano -e micro -e vi -e EDITOR'
    local default_nvim = io.popen('rifle -l ' .. open_path .. '| head -n 1 | grep ' .. grep_opts)-- .. grep_opts)
    local len_string = #default_nvim:read('*a')

    if (len_string > 0) or (status == 124) then
        -- Open with nvim
        vim.cmd('edit ' .. open_path)
        vim.cmd('filetype detect')
    else
        -- open with rifle
        os.execute('rifle ' .. open_path)
        local dir = string.gsub(open_path, "(.*/)(.*)", "%1")
        create_window()
        open_ranger(dir)
        vim.api.nvim_feedkeys("i", "m", false)
    end
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

set_auto_cmd()
local function ranger_nvim()
    create_window()
    open_ranger()
end

return {
    ranger_nvim = ranger_nvim
}

