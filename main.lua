-- -- main.lua
-- local circle = {
--     x = 100,
--     y = 100,
--     radius = 20,
--     speed = 100
-- }

-- function love.load()
--     love.window.setTitle("LÖVE Test - Moving Circle")
--     love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
-- end

-- function love.update(dt)
--     -- Move the circle to the right
--     circle.x = circle.x + circle.speed * dt
    
--     -- Bounce back when it reaches the edge
--     if circle.x > love.graphics.getWidth() - circle.radius or circle.x < circle.radius then
--         circle.speed = -circle.speed
--     end
-- end

-- function love.draw()
--     love.graphics.setColor(0, 1, 0)  -- Set color to green
--     love.graphics.circle("fill", circle.x, circle.y, circle.radius)
-- end

-- Testing the Memory class
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
local clockSpeed = 500  -- Adjust this value as needed

-- Calculate delay based on clock speed (in seconds)
local delay = 1 / clockSpeed

-- Run CPU clock cycle in a loop
while true do
    -- Execute one CPU cycle
    c8:tick()
    print(string.format("Running CPU clock cycle: %d.. Current OP Code: 0x%04X", c8:getCycles(), c8:getCurrentOp()))

    -- Optional: Sleep to simulate the clock speed
    os.execute("sleep " .. delay)
end