local DisplayBuffer = {}
DisplayBuffer.__index = DisplayBuffer

-- Constructor
function DisplayBuffer:new(width, height, pixelSize)
    local instance = setmetatable({}, DisplayBuffer)
    instance.width = width or 64
    instance.height = height or 32
    instance.pixelSize = pixelSize or 10
    instance.buffer = {}

    -- Initialize buffer
    for y = 1, instance.height do
        instance.buffer[y] = {}
        for x = 1, instance.width do
            instance.buffer[y][x] = 0  -- 0 for off, 1 for on
        end
    end

    return instance
end

-- Method to clear the buffer
function DisplayBuffer:clear()
    for y = 1, self.height do
        for x = 1, self.width do
            self.buffer[y][x] = 0
        end
    end
end

-- Method to set a pixel in the buffer
-- This toggles the pixel and returns true if there's a collision
function DisplayBuffer:setPixel(x, y)
    if x < 1 or x > self.width or y < 1 or y > self.height then
        return false  -- Ignore out-of-bounds
    end

    -- XOR to toggle the pixel
    self.buffer[y][x] = self.buffer[y][x] ~ 1
    return self.buffer[y][x] == 0  -- Return true if the pixel was turned off (collision)
end

-- Method to draw the buffer to the screen using LOVE
function DisplayBuffer:draw()
    for y = 1, self.height do
        for x = 1, self.width do
            if self.buffer[y][x] == 1 then
                love.graphics.rectangle(
                    "fill",
                    (x - 1) * self.pixelSize,
                    (y - 1) * self.pixelSize,
                    self.pixelSize,
                    self.pixelSize
                )
            end
        end
    end
end

return DisplayBuffer