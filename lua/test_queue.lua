-- Assuming the createQueue function is defined above or imported
local createQueue = require("queue") -- Adjust the path as necessary

-- Function to print the content of the queue for testing
local function printQueue(queue)
    print("Queue content:")
    for i, v in queue:ipairs() do
        print(i, v)
    end
end

-- Test 1: Create a queue and enqueue items
local queueSize = 10
local queue = createQueue(queueSize)
print("Test 1: Enqueue")
for i = 0, 20 do
    queue:enqueue(i)
    print("Enqueued:", i)
end
printQueue(queue)

-- Test 2: Enqueue beyond maxSize and test automatic dequeue
print("\nTest 2: Enqueue beyond maxSize")
queue:enqueue(queueSize + 1)
print("Enqueued:", queueSize + 1)
printQueue(queue)

-- Test 3: Dequeue items
print("\nTest 3: Dequeue")
while true do
    local status, value = pcall(queue.dequeue, queue)
    if not status then
        print("Dequeue failed:", value)
        break
    else
        print("Dequeued:", value)
    end
end

-- Test 4: Test the pairs iterator (if intended to work like ipairs but without indices)
print("\nTest 4: Testing pairs iterator")
for i = 1, 3 do
    queue:enqueue(i * 10)
end
print("Queue content using custom pairs:")
for value in queue:pairs() do
    print(value)
end
