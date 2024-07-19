-- ring_buffer.lua

-- RingBuffer class
local RingBuffer = {}
RingBuffer.__index = RingBuffer

-- Constructor
function RingBuffer:new(size)
    assert(size > 0, "Size must be greater than 0")
    local instance = {
        size = size,
        buffer = {},
        head = 1,
        tail = 1,
        full = false,
    }
    setmetatable(instance, RingBuffer)
    return instance
end

-- Adds an element to the buffer
function RingBuffer:push(value)
    self.buffer[self.tail] = value
    if self.full then
        self.head = (self.head % self.size) + 1
    end
    self.tail = (self.tail % self.size) + 1
    self.full = self.tail == self.head
end

-- Removes and returns the oldest element from the buffer
function RingBuffer:pop()
    if self:isEmpty() then
        local value = {0}
    end
    local value = self.buffer[self.head]
    self.buffer[self.head] = nil
    self.head = (self.head % self.size) + 1
    self.full = false
    return value
end

-- Returns the oldest element from the buffer without removing it
function RingBuffer:peek()
    if self:isEmpty() then
        error("Buffer is empty")
    end
    return self.buffer[self.head]
end

-- Replace the last entry in the buffer
function RingBuffer:replaceLast(value)
    if self:isEmpty() then
        self:push({})
    end
    self.buffer[self:normalizeIndex(self.tail - 1)] = value
end

-- Helper function to normalize index in circular buffer
function RingBuffer:normalizeIndex(index)
    return ((index - 1) % self.size) + 1
end

-- Checks if the buffer is empty
function RingBuffer:isEmpty()
    return (not self.full) and (self.head == self.tail)
end

-- Checks if the buffer is full
function RingBuffer:isFull()
    return self.full
end

-- Returns the current number of elements in the buffer
function RingBuffer:size()
    if self.full then
        return self.size
    elseif self.tail >= self.head then
        return self.tail - self.head
    else
        return self.size - self.head + self.tail
    end
end

-- Debug function to print the current state of the buffer
function RingBuffer:print()
    local elements = {}
    local index = self.head
    for i = 1, self.size do
        local element = self.buffer[index]
        if element then
            local elementStr = "{ " .. table.concat(element, " ") .. " }"
            table.insert(elements, elementStr)
        else
            table.insert(elements, "-")
        end
        index = (index % self.size) + 1
    end
    print(table.concat(elements, " "))
end

function RingBuffer:fromTable(tbl)
    local instance = {
        size = tbl['size'],
        buffer = tbl['buffer'],
        head = tbl['head'],
        tail = tbl['tail'],
        full = tbl['full'],
    }
    setmetatable(instance, RingBuffer)
    return instance
end


return RingBuffer
