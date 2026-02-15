local M = {}

function M.starts_with(str, prefix)
    return string.sub(str, 1, string.len(prefix)) == prefix
end

function M.get_relative_file_path()
    local full_path = vim.api.nvim_buf_get_name(0)
    -- In case one of the following conditions apply, use the cwd.
    -- - We aren't in a file buffer.
    -- - The filename is empty.
    -- - The path isn't absolute.
    if full_path == nil or
        full_path == '' or
        not M.starts_with(full_path, '/') then
        return '.'
    end

    -- Return the relative path of the buffer to the current cwd.
    -- That's what proximity sort expects.
    local cwd = vim.fn.getcwd()

    -- If we are in some nestewd directory inside the cwd, return the relative path
    if M.starts_with(full_path, cwd) then
        return string.sub(full_path, string.len(cwd) + 2)
    end

    -- Otherwise fallback to cwd
    return '.'
end

function M.is_git_file()
    return M.starts_with(vim.bo.filetype, "git")
end

return M
