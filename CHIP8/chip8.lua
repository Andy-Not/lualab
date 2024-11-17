package.path = "./CHIP8/dkjson/?.lua;./CHIP8/?.lua;/Users/nicholasgarman/.luarocks/share/lua/5.3/?.lua;/Users/nicholasgarman/.luarocks/share/lua/5.3/?/init.lua;" .. package.path
package.cpath = "/Users/nicholasgarman/.luarocks/lib/lua/5.3/?.so;" .. package.cpath

json = require ("dkjson")
local http_request = require("http.request")
print("Package path: " .. package.path)

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
    
    -- Check if currentDisplay is non-empty and valid
    if currentDisplay and #currentDisplay > 0 then
        -- Send the entire display buffer once
        self:sendDisplayBuffer()
    else
        print("Display buffer is empty or nil")
    end
end



-- local json = require("json")  -- You may need to install a JSON library for Lua

-- Function to send display buffer to Flask server
function Chip8:sendDisplayBuffer()
    local url = "http://127.0.0.1:5000/update_display"

    -- print("Display Buffer Before Sending:")
    -- for i = 1, #self.memory.displayBuffer do
    --     io.write(self.memory.displayBuffer[i] .. " ")
    --     if i % 64 == 0 then io.write("\n") end
    -- end
    -- print("\n")
    
    -- Convert displayBuffer (1D array) to JSON format as an object
    print("Display Buffer:", self.memory:getDisplayBuffer()) 
    -- local data = json.encode({ displayBuffer = displayBuffer })
    -- print("Encoded JSON Data:", data)
    local data = json.encode({ displayBuffer = self.memory:getDisplayBuffer() })
    if not data then
        print("Error encoding display buffer to JSON")
    else
        print("Encoded JSON data:", data)
    end

    
    -- Create a new HTTP request
    local req = http_request.new_from_uri(url)
    req.headers:upsert(":method", "POST")
    req.headers:upsert("Content-Type", "application/json")
    req:set_body(data)
    
    -- Send the request and read the response
    local headers, stream = req:go()
    if not headers then
        print("Failed to send display buffer")
        return
    end

    local response_body = stream:get_body_as_string()
    print("Response:", response_body)
end


return Chip8