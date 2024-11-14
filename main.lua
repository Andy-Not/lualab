
local Chip8 = require("CHIP8.chip8")

-- Get the file path from the command-line argument
local filePath = arg[1]
if not filePath then
    error("Please provide a file path for the program.")
end

-- Create a new Chip8 instance with the specified file path
local c8 = Chip8:new(filePath)
c8:loadProgram()

-- Define a clock speed, e.g., 500 cycles per second
local clockSpeed = 400  -- Adjust this value as needed

-- Calculate delay based on clock speed (in seconds)
local delay = 1 / clockSpeed
-- local delay = 0.05


-- Run CPU clock cycle in a loop
while true do
    -- Execute one CPU cycle
    c8:tick()
    print(string.format("Running CPU clock cycle: %d.. Current OP Code: 0x%04X", c8:getCycles(), c8:getCurrentOp()))

    -- Optional: Sleep to simulate the clock speed
    os.execute("sleep " .. delay)

    c8:updateDisplay()
    
end

