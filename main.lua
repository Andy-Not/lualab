
local Chip8 = require("CHIP8.chip8")
local filePath = arg[1]

if not filePath then
    error("Please provide a file path for the program.")
end

local c8 = Chip8:new(filePath)
c8:loadProgramFromFile()

local clockSpeed = 400  -- in Mhz


-- Calculate the delay between CPU cycles based on the clock speed
local delay = 1 / clockSpeed


while true do
    -- Execute one CPU cycle
    c8:tick()
    print(string.format("Running CPU clock cycle: %d.. Current OP Code: 0x%04X", c8:getCycles(), c8:getCurrentOp()))
    os.execute("sleep " .. delay)

    c8:updateDisplay()
    
end

