local Memory = require("CHIP8.memory")
local Cpu = require("CHIP8.cpu")

Chip8 = {}
Chip8.__index = Chip8

-- Chip8.lua
local Memory = require("CHIP8.memory")
local Cpu = require("CHIP8.cpu")

Chip8 = {}
Chip8.__index = Chip8

function Chip8:new(programPath)
    local instance = setmetatable({}, Chip8)
    instance.filePath = programPath

    -- Initialize Memory and Cpu
    instance.memory = Memory:new(4096)
    instance.cpu = Cpu:new(instance.memory, instance)  -- Pass instance as a reference

    -- Initialize 64x32 graphics buffer
    instance.graphics = {}
    for y = 1, 32 do
        instance.graphics[y] = {}
        for x = 1, 64 do
            instance.graphics[y][x] = 0
        end
    end

    return instance
end

function Chip8:getDisplayBuffer()
    return self.memory.getDisplayBuffer()
end

function Chip8:loadProgram()
    local file = io.open(self.filePath, "rb")
    if not file then
        error("Could not open file: " .. tostring(self.filePath))
        return
    end

    local programData = file:read("*a")
    if not programData then
        error("Failed to read program data from file: " .. tostring(self.filePath))
        file:close()
        return
    end

    for i = 1, #programData do
        self.memory:writeByte(0x200 + i - 1, programData:byte(i))
    end

    file:close()
end

-- function Chip8:loadProgram()
--     local file = io.open(self.filePath, "rb")
--     if file then
--         local programData = file:read("*a")
--         for i = 1, #programData, 1 do
--             self.memory:writeByte(0x200 + i - 1, programData:byte(i))
--         end
--         file:close()
--     end
-- end

function Chip8:getCycles()
    return self.cpu:getCycles()
end

function Chip8:tick()
    self.cpu:cycle()
end

function Chip8:getCurrentOp()
    return self.cpu:currentOp()
end

function Chip8:updateDisplay()
    local currentDisplay = self.memory:getDisplayBuffer()
    for y = 1, 32 do
        for x = 1, 64 do
            if (currentDisplay[y * 64 + x] == 1) then
                -- then send the updated displayData to the flask server
                
                
            end
        end
    end
end


return Chip8