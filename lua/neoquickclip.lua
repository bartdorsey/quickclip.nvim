M = {}

M.setup = function(opts)
    print("Setup")
end

local history = vim.ringbuf(10)
local window = nil

vim.api.nvim_create_autocmd("TextYankPost", {
    callback = function()
        -- Make a deep copy right away to try to reduce
        -- race conditions caused by multiple yanks
        local contents = vim.deepcopy(vim.v.event.regcontents)
        -- Check for empty yanks
        if #contents == 1 and contents[1]:match("^$s*$") then
            print("Empty Line")
            return
        end
        -- Check history to see if we already have an indentical entry
        for entry in history do
            print("contents" .. vim.inspect(contents))
            print("entry" .. vim.inspect(entry))
            if vim.deep_equal(entry, contents) then
                print("Duplicate Line")
                return
            end
        end

        print("Yanked")
        history:push(contents)
        for val in history do
            print(vim.inspect(val))
        end
    end,
})

local function render_history_ui()
    local output = {}
    local i = 0
    for value in history do
        table.insert(output, string.format("%2i %s", i, value[1]))
        i = i + 1
    end
    return output
end

-- Quickclip open
M.quickclip_open = function()
    if window ~= nil then
        return
    end
    -- get current window size
    local win_width = vim.api.nvim_win_get_width(0)
    local win_height = vim.api.nvim_win_get_height(0)
    local height = 10
    local width = 40

    local buf = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_buf_set_lines(buf, 0, 1, true, render_history_ui())

    window = vim.api.nvim_open_win(buf, false, {
        relative = "win",
        title = " quickclip",
        title_pos = "center",
        row = (win_height / 2) - (height / 2),
        col = (win_width / 2) - (width / 2),
        width = width,
        height = height,
        border = "rounded",
        style = "minimal",
    })
end

M.quickclip_close = function()
    if window == nil then
        return
    end
    vim.api.nvim_win_close(window, true)
    window = nil
end

-- QuickClip command
vim.api.nvim_create_user_command(
    "QuickClip",
    M.quickclip_open,
    { desc = "Open QuickClip Menu" }
)

-- QuickClipClose command
vim.api.nvim_create_user_command(
    "QuickClipClose",
    M.quickclip_close,
    { desc = "Close QuickClip Menu" }
)

return M
