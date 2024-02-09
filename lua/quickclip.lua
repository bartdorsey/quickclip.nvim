M = {}

M.setup = function(opts)
    print("Setup")
end

local history = {}
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
        for entry in pairs(history) do
            print("contents" .. vim.inspect(contents))
            print("entry" .. vim.inspect(entry))
            if vim.deep_equal(entry, contents) then
                print("Duplicate Line")
                return
            end
        end

        print("Yanked")
        table.insert(history, contents)
        for val in pairs(history) do
            print(vim.inspect(val))
        end
    end,
})

local function render_history_ui()
    local output = {}
    for i, value in ipairs(history) do
        table.insert(output, string.format("%2i > %s", i, value[1]))
    end
    return output
end

-- Quickclip open
M.quickclip_open = function()
    local current_win = vim.api.nvim_get_current_win()
    if current_win == nil then
        print("No current window")
        return
    end
    local current_pos = vim.api.nvim_win_get_cursor(current_win)

    if window ~= nil then
        return
    end
    -- get current window size
    local win_width = vim.api.nvim_win_get_width(0)
    local win_height = vim.api.nvim_win_get_height(0)
    local height = 10
    local width = 50

    local buf = vim.api.nvim_create_buf(false, true)

    vim.api.nvim_buf_set_lines(buf, 0, 1, true, render_history_ui())

    vim.api.nvim_buf_set_keymap(buf, "n", "q", "<cmd>QuickClipClose<cr>", {})

    window = vim.api.nvim_open_win(buf, true, {
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
    -- Set keymaps for items in the list
    for i, value in ipairs(history) do
        vim.api.nvim_buf_set_keymap(buf, "n", string.format("%s", i), "", {
            callback = function()
                vim.api.nvim_set_current_win(current_win)
                vim.api.nvim_win_set_cursor(current_win, current_pos)
                vim.api.nvim_put(value, "c", true, true)
                vim.api.nvim_win_close(window, true)
                vim.api.nvim_buf_delete(buf, { force = true })
            end,
        })
    end
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
