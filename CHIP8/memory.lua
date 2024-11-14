

-- Define the Memory class
Memory = {}
Memory.__index = Memory


-- Constructor to create a new memory instance
function Memory:new(size)
    local instance = setmetatable({}, Memory) -- Essentially an array
    instance.size = size or 4096 -- default size (4096bytes)
    instance.displayBuffer = {} -- Our display buffer 
    instance.data = {} -- Table to store bytes


    for i = 1, 64 * 32 do
        instance.displayBuffer[i] = 0
    end
    
    -- Initialize memory to zero
    for i = 0, instance.size - 1 do
        instance.data[i] = 0
    end

    return instance
end

-- Method to read a byte at a specific address
function Memory:readByte(address)
    if address < 0 or address >= self.size then
        error("Memory read out of bounds at address: " .. address)
    end
    return self.data[address]
end

-- Method to write a byte to a specific address
function Memory:writeByte(address, value)
    if address < 0 or address >= self.size then
        error("Memory write out of bounds at address: " .. address)
    end
    self.data[address] = value & 0xFF -- Ensure only the lower 8 bits are stored
end

-- Method to read a 16-bit word (2 bytes) at a specific address
function Memory:readWord(address)
    local low = self:readByte(address)
    local high = self:readByte(address + 1)
    return (high << 8) | low
end

-- Method to write a 16-bit word (2 bytes) to a specific address
function Memory:writeWord(address, value)
    self:writeByte(address, value & 0xFF)         -- Write lower byte
    self:writeByte(address + 1, (value >> 8) & 0xFF) -- Write higher byte
end

-- Method to load data (array of bytes) into memory starting at a specific address
function Memory:loadData(startAddress, data)
    for i = 1, #data do
        local address = startAddress + i - 1
        if address >= self.size then
            error("Memory load out of bounds")
        end
        self.data[address] = data[i] & 0xFF -- Ensure only 8 bits are stored
    end
end

function Memory:getDisplayBuffer()
    return self.displayBuffer;
end

function Memory:clearDisplay()
    for i = 1, #self.displayBuffer do
        self.displayBuffer[i] = 0
    end
end

function Memory:loadFont()
    local fontData = {
        0xF0, 0x90, 0x90, 0x90, 0xF0, -- 0
        0x20, 0x60, 0x20, 0x20, 0x70, -- 1
        0xF0, 0x10, 0xF0, 0x80, 0xF0, -- 2
        0xF0, 0x10, 0xF0, 0x10, 0xF0, -- 3
        0x90, 0x90, 0xF0, 0x10, 0x10, -- 4
        0xF0, 0x80, 0xF0, 0x10, 0xF0, -- 5
        0xF0, 0x80, 0xF0, 0x90, 0xF0, -- 6
        0xF0, 0x10, 0x20, 0x40, 0x40, -- 7
        0xF0, 0x90, 0xF0, 0x90, 0xF0, -- 8
        0xF0, 0x90, 0xF0, 0x10, 0xF0, -- 9
        0xF0, 0x90, 0xF0, 0x90, 0x90, -- A
        0xE0, 0x90, 0xE0, 0x90, 0xE0, -- B
        0xF0, 0x80, 0x80, 0x80, 0xF0, -- C
        0xE0, 0x90, 0x90, 0x90, 0xE0, -- D
        0xF0, 0x80, 0xF0, 0x80, 0xF0, -- E
        0xF0, 0x80, 0xF0, 0x80, 0x80  -- F
    }

    for i = 0, #fontData-1 do -- '#' gets the length of the table 
        self:writeByte(i, fontData[i+1])
    end
end

return Memory