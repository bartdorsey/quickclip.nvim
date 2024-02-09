-- Define the queue with a given max size
local function createQueue(maxSize)
    local self = {
        items = {},
        maxSize = maxSize + 1,
    }

    -- Enqueue an item
    function self:enqueue(value)
        if #self.items == self.maxSize then
            -- Remove the oldest item if we hit the max size
            table.remove(self.items)
        end
        table.insert(self.items, 1, value)
    end

    -- Dequeue an item
    function self:dequeue()
        if #self.items == 0 then
            error("Queue is empty")
        end
        local value = self.items.remove(self.items)
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

    -- ipairs iterator
    function self:pairs()
        local function iter(_, i)
            i = i + 1
            local v = self.items[i]
            if v then
                return v
            end
        end
        return iter, nil, 0
    end

    return self
end

return createQueue
