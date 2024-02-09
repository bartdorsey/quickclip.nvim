M = {}

--- @class QuickClipOptions
--- @field public icon? string

-- Define the queue with a given max size
local function createQueue(maxSize)
    local self = {
        items = {},
        first = 0,
        last = -1,
        maxSize = maxSize,
    }

    -- Enqueue an item
    function self:enqueue(value)
        print(vim.inspect(self))
        if #self.items == self.maxSize then
            -- Remove the oldest item if we hit the max size
            table.remove(self.items, 1)
        else
            self.last = self.last + 1
        end
        self.items[self.last] = value
    end

    -- Dequeue an item
    function self:dequeue()
        if self.first > self.last then
            error("Queue is empty")
        end
        local value = self.items[self.first]
        self.items[self.first] = nil -- Remove the item
        self.first = self.first + 1
        return value
    end

    -- ipairs iterator
    function self:ipairs()
        local function iter(_, i)
            i = i + 1
            local v = self.items[i]
            if v then
                return i, v
            end
        end
        return iter, nil, 0
    end

    -- pairs iterator (same as ipairs in this context)
    self.pairs = self.ipairs

    return self
end

--- QuickClip Setup
---@param opts? QuickClipOptions
---@return nil
M.setup = function(opts)
    opts = opts or {}
    -- State variables
    local history = createQueue(10)
    local quickclip_window = nil
    local icon = opts.icon or ""

    -- When someone yanks, grab the text and store it in the history
    vim.api.nvim_create_autocmd("TextYankPost", {
        callback = function()
            -- Make a deep copy right away to try to reduce
            -- race conditions caused by multiple yanks
            local contents = vim.deepcopy(vim.v.event.regcontents)

            -- Check for empty yanks
            if #contents == 1 and contents[1]:match("^$s*$") then
                return
            end

            -- Check history to see if we already have an indentical entry
            for _, entry in history:ipairs() do
                if vim.deep_equal(entry, contents) then
                    print("Duplicate Line")
                    return
                end
            end

            -- Insert the entry into the history table
            history:enqueue(contents)
            for val in history:pairs() do
                print(vim.inspect(val))
            end
        end,
    })

    -- Render the contents of the window
    local function render_history_ui()
        local output = {}
        for i, value in history:ipairs() do
            table.insert(output, string.format("%2i > %s", i, value[1]))
        end
        return output
    end

    -- Quickclip open
    M.quickclip_open = function()
        -- Get the current window we will be pasting into
        local current_win = vim.api.nvim_get_current_win()
        if current_win == nil then
            print("No current window")
            return
        end
        local current_pos = vim.api.nvim_win_get_cursor(current_win)

        if quickclip_window ~= nil then
            return
        end

        -- get current window size
        local win_width = vim.api.nvim_win_get_width(0)
        local win_height = vim.api.nvim_win_get_height(0)
        local height = 10
        local width = 50

        -- Create a new buffer to hold the ui
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, 1, true, render_history_ui())

        -- Set q to close
        vim.api.nvim_buf_set_keymap(
            buf,
            "n",
            "q",
            "<cmd>QuickClipClose<cr>",
            {}
        )
        -- Set esc to also close
        vim.api.nvim_buf_set_keymap(
            buf,
            "n",
            "<esc>",
            "<cmd>QuickClipClose<cr>",
            {}
        )

        -- Open the quickclip window
        quickclip_window = vim.api.nvim_open_win(buf, true, {
            relative = "win",
            title = icon .. " quickclip",
            title_pos = "center",
            row = (win_height / 2) - (height / 2),
            col = (win_width / 2) - (width / 2),
            width = width,
            height = height,
            border = "rounded",
            style = "minimal",
        })

        -- Set keymaps for items in the list
        for i, value in history:ipairs() do
            vim.api.nvim_buf_set_keymap(buf, "n", string.format("%s", i), "", {
                callback = function()
                    vim.api.nvim_set_current_win(current_win)
                    vim.api.nvim_win_set_cursor(current_win, current_pos)
                    vim.api.nvim_put(value, "c", true, true)
                    vim.api.nvim_win_close(quickclip_window, true)
                    vim.api.nvim_buf_delete(buf, { force = true })
                    quickclip_window = nil
                end,
            })
        end
    end

    -- Close the quickclip window
    M.quickclip_close = function()
        if quickclip_window == nil then
            return
        end
        vim.api.nvim_win_close(quickclip_window, true)
        quickclip_window = nil
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
end

return M
