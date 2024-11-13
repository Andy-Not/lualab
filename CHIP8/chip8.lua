local Memory = require("CHIP8.memory")
local Cpu = require("CHIP8.cpu")

Chip8 = {}
Chip8.__index = Chip8

function Chip8:new(programPath)
    local instance = setmetatable({}, Chip8)
    instance.filePath = programPath

    -- Create a new Memory instance and pass it to the CPU
    instance.memory = Memory:new(4096)       -- New memory instance for this Chip8 instance
    instance.cpu = Cpu:new(instance.memory)  -- New CPU instance with memory

    return instance
end

function Chip8:loadProgram()
    local file = io.open(self.filePath, "rb")
    if file then
        local programData = file:read("*a")
        for i = 1, #programData, 1 do
            self.memory:writeByte(0x200 + i - 1, programData:byte(i))
        end
        file:close()
    end
end

function Chip8:getCycles()
    return self.cpu:getCycles()
end

function Chip8:tick()
    self.cpu:cycle()
end

function Chip8:getCurrentOp()
    return self.cpu:currentOp()
end


return Chip8