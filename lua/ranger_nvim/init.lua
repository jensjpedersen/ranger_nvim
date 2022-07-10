local tmp_path = '/tmp/ranger_nvim_tmp'

local function open_ranger()
    if io.open(tmp_path) ~= nil then
        os.execute('rm ' .. tmp_path)
    end
    vim.api.nvim_command('terminal ranger --choosefile ' .. tmp_path)
end

local function read_ranger_tmp()
    local tmp_file=io.open(tmp_path)

    if tmp_file == nil then
        return nil
    end

    local open_path = tmp_file:read('*l')
    io.close(tmp_file)
    return open_path
end

local function open_default_program()
    vim.api.nvim_command('bdelete!')                 -- Delete buffer
    local open_path = read_ranger_tmp()              -- Get selected ranger file path
    if open_path == nil then
        return                                       -- Exit if tmp does not exist
    end

    local default_nvim = io.popen('rifle -l ' .. open_path .. '| grep nvim')
    local len_string = #default_nvim:read('*a')

    if (len_string > 0) then
        -- Open with nvim
        vim.cmd('edit ' .. open_path)
        vim.cmd('edit %')
        os.execute('echo ' .. type(open_path) .. ' >> ~/test_path')
    else
        -- open with rilfe
        os.execute('rifle ' .. open_path)
    end
end

local function set_auto_cmd()
    vim.api.nvim_create_autocmd({"BufWinEnter", "TermOpen"}, {
        pattern = {"term://*ranger*"},
        command = "set nonumber norelativenumber signcolumn=no",
    })

    vim.api.nvim_create_autocmd({"BufWinLeave", "TermClose"}, {
        pattern = {"term://*ranger*"},
        command = "set number relativenumber signcolumn=yes"
    })

    -- Deletes terminal buffer and opens path in default rifle program
    vim.api.nvim_create_autocmd({"TermClose"}, {
        pattern = {"term://*ranger*"},
        callback = open_default_program
    })
end

set_auto_cmd()
local function ranger_nvim()
    open_ranger()
end

return {
    open_ranger = open_ranger,
    set_auto_cmd = set_auto_cmd,
    ranger_nvim = ranger_nvim
}

