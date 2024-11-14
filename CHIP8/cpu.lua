-- Define the CPU class
local Memory = require("CHIP8.memory")
local Uint = require("../UINT.uint")

Cpu = {}
Cpu.__index = Cpu

function Cpu:new(memory)
    local instance = setmetatable({}, Cpu)
    instance.memory = memory -- Assign memory or create new Memory instance
    instance.registers = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}  -- V0 to VF Register Array
    instance.regI = 0 -- Index Register

    instance.soundTimer = 0
    instance.delayTimer = 0
 
    instance.SP = 0 -- stack pointer
    instance.PC = 0x200 -- starting the program counter at 0x200 (where the program begins in memory)
    instance.stack = {}
    instance.cycles = 0
    instance.paused = false -- cpu operation status

    return instance
end

function Cpu:cycle()
    if self.paused then
        return  -- Exit the function if the CPU is paused
    end

    self:decode() -- otherwise lets decode the next instruction -- remember that we have to use : sometimes to make sure we are referencing our current object. 
    self.cycles = self.cycles + 1 -- no ++ or += in Lue :( 

end

function Cpu:getCycles() return self.cycles end

function Cpu:currentOp()
    local highByte = self.memory:readByte(self.PC)
    local lowByte = self.memory:readByte(self.PC + 1)
    return (highByte << 8) | lowByte  -- Combine high and low bytes to form 16-bit opcode
end

-- all of these are assuming that the value is already in hexadecimal format
function Cpu:setRegister(name, value)
    self.registers[name] = value
end

function Cpu:setPC(location)
    self.PC = location
end

-- pops an instruction off of the stack
function Cpu:pop()
    if self.SP <= 0 then
        -- throw some error
        return -1
    end
    self.SP = self.SP - 1 -- decremenet the stack pointer by one
    return self.stack[self.SP]
end

-- pushes an instruction onto the stack
function Cpu:push(instruction)
    if self.SP >= 15 then
        -- throw some stack overflow attempt error
        return -1
    end
    self.stack[self.SP] = instruction
    self.SP = self.SP + 1 -- increment the stack pointer by one
end


-- OPCODE IMPLEMENTATION BELOW -- 

-- Begins the decode process of decoding the opcodes. 
-- function Cpu:decode()
--     -- Correctly read two bytes and combine them into a 16-bit instruction
--     local highByte = self.memory:readByte(self.PC)
--     local lowByte = self.memory:readByte(self.PC + 1)
--     local instruction = (highByte << 8) | lowByte  -- Combine to form 16-bit instruction

--     -- Extract opcode components
--     local n = (instruction >> 12) & 0x0F
--     local nnn = instruction & 0x0FFF
--     local x = (instruction >> 8) & 0x0F
--     local y = (instruction >> 4) & 0x0F
--     local kk = instruction & 0x00FF
--     self:processOpcode(n, nnn, x, y, kk)

-- end

function Cpu:decode()
    -- Correctly read two bytes and combine them into a 16-bit instruction
    local highByte = self.memory:readByte(self.PC)
    local lowByte = self.memory:readByte(self.PC + 1)
    local instruction = (highByte << 8) | lowByte  -- Combine to form 16-bit instruction

    -- Store the instruction in self.instruction
    self.instruction = instruction

    -- Extract opcode components
    local n = (instruction >> 12) & 0x0F
    local nnn = instruction & 0x0FFF
    local x = (instruction >> 8) & 0x0F
    local y = (instruction >> 4) & 0x0F
    local kk = instruction & 0x00FF
    self:processOpcode(n, nnn, x, y, kk)
end

function Cpu:processOpcode(n, nnn, x, y, kk)
    -- no switch statements in lue so we will have to do a bunch of if-thens
    -- this just further breaks down the opcode into their own corresponding functions. 
    if n == 0 then self:decodeZero(nnn) end
    if n == 1 then self:decodeOne(nnn) end
    if n == 2 then self:decodeTwo(nnn) end
    if n == 3 then self:decodeThree(x, kk) end
    if n == 4 then self:decodeFour(x, kk) end
    if n == 5 then self:decodeFive(x, y) end
    if n == 6 then self:decodeSix(x, kk) end
    if n == 7 then self:decodeSeven(x, kk) end
    if n == 8 then self:decodeEight(nnn, x, y) end
    if n == 9 then self:decodeNine(x, y) end
    if n == 0xA then self:decodeA(nnn) end
    if n == 0xB then self:decodeB(nnn) end
    if n == 0xC then self:decodeC(x, kk) end
    if n == 0xD then self:decodeD(nnn, x, y) end
    if n == 0xE then self:decodeE(nnn, x, y, kk) end
    if n == 0xF then self:decodeF(nnn, x, y, kk) end
end

function Cpu:decodeZero(nnn) 
    local lastChar = (nnn & 0x000F)
    if lastChar == 0x0 then 
        -- then clear the display
        self.memory:clearDisplay()
        print("Clearing display!")
        self.PC = self.PC + 2
        return
    end
    if lastChar == 0xE then -- return from sub routine 
        self.PC = self:pop()
        return
    end
    -- we are not implementing 0nnn, so if there is an attempt at decoding it then just skip it and increment the program counter
    self.PC = self.PC + 2

end

-- sets the program counter to nnn
function Cpu:decodeOne(nnn) self.PC = nnn end

function Cpu:decodeTwo(nnn)
    self:push(self.PC + 2) -- we need to use the colon ':' character 
                           -- to indicate that we are refering to our own class function and not lua's built in .push function. 
    self.PC = nnn
end

function Cpu:decodeThree(x, kk)
    if self.registers[x] == kk then -- skipping to the next instruction 
        self.PC = self.PC + 4       -- if the value at register @x is equal to value of kk
        return
    end
    -- otherwise increment by 2
    self.PC = self.PC + 2
end

function Cpu:decodeFour(x, kk)
    if self.registers[x] ~= kk then -- skipping to the next instruction 
        self.PC = self.PC + 4       -- if the value at register @x is not equal to value of kk
        return
    end                                                  

    -- otherwise just increment the PC by 2. 
    self.PC = self.PC + 2
end

function Cpu:decodeFive(x, y)
    if self.registers[x] == self.registers[y] then -- skipping to the next instruction 
        self.PC = self.PC + 4  -- if the value at register @x is equal to value of register @y
        return
    end
    self.PC = self.PC + 2
end

-- puts the vlaue kk into register @x
function Cpu:decodeSix(x, kk)
    self.registers[x] = kk
    self.PC = self.PC + 2
end

function Cpu:decodeSeven(x, kk)
    self.registers[x] = ((self.registers[x] + kk) & 0xFF)
    self.PC = self.PC + 2
end


function Cpu:decodeEight(nnn, x, y) 
    local lastFourBits = (nnn & 0x000F)
    if lastFourBits == 0x0 then -- 8xy0
        self.registers[x] = self.registers[y]
        self.PC = self.PC + 2
        return
    end

    if lastFourBits == 0x1 then -- 8xy1
        self.registers[x] = self.registers[x] | self.registers[y]
        self.PC = self.PC + 2
        return
    end

    if lastFourBits == 0x2 then -- 8xy2
        self.registers[x] = self.registers[x] & self.registers[y]
        self.PC = self.PC + 2
        return
    end

    if lastFourBits == 0x3 then -- 8xy3
        self.registers[x] = self.registers[x] ~ self.registers[y] -- in Lua 5.3+ the XOR (exclusive OR) operator is '~'. 
        self.PC = self.PC + 2
        return
    end

    -- -- handles overflow 
    -- if lastFourBits == 0x4 then -- 8xy4
    --     local vx  = self.registers[x] & 0xFF
    --     local vy = self.registers[y] & 0xFF
    --     local result = vx + vy

    --     -- set the carry flag (reg F) if the result is > 255 otherwise set it to 0
    --     if (result > 255) then self.registers[0xF] = 1 else self.registers[0xF] = 0 end

    --     self.registers[x] = result & 0xFF
    --     self.PC = self.PC + 2
    --     return
    -- end

    if lastFourBits == 0x4 then -- 8xy4
        local vx  = self.registers[x] & 0xFF
        local vy = self.registers[y] & 0xFF
        local result = vx + vy
    
        -- set the carry flag (reg F) if the result is > 255 otherwise set it to 0
        if (result > 255) then self.registers[0xF] = 1 else self.registers[0xF] = 0 end
    
        self.registers[x] = result & 0xFF
        self.PC = self.PC + 2
        return
    end

    if lastFourBits == 0x5 then -- 8xy5
        if self.registers[x] >= self.registers[y] then
            self.registers[0xF] = 1
        else
            self.registers[0xF] = 0
        end
        self.registers[x] = (self.registers[x] - self.registers[y]) & 0xFF  -- Mask to 8 bits
        self.PC = self.PC + 2
        return
    end

    -- -- handles overflow
    -- if lastFourBits == 0x5 then -- 8xy5
    --    if (self.registers[x] > self.registers[y]) then 
    --         self.registers[0xF] = 1 
    --         self.registers[x] = self.registers[x] - self.registers[y]
    --         self.PC = self.PC + 2
    --         return
    --     end
    --     self.registers[0xF] = 0
    --     self.registers[x] = self.registers[x] - self.registers[y]
    --     self.PC = self.PC + 2
    --     return
    -- end

    if lastFourBits == 0x6 then -- 8xy6
        -- Set VF to the least significant bit of reg x
        self.registers[0xF] = self.registers[x] & 1  -- Get the LSB of Vx directly
    
        -- Perform the right shift on reg x
        self.registers[x] = self.registers[x] >> 1

        self.PC = self.PC + 2
        return
    end

    -- if lastFourBits == 0x6 then -- 8xy6
    --     -- Set VF to the least significant bit of Vx
    --     self.registers[0xF] = self.registers[x] % 2  -- Get LSB of Vx
    
    --     -- Shift Vx to the right by 1 using integer division
    --     self.registers[x] = (self.registers[x] - self.registers[x] % 2) / 2
        
    --     -- Advance the program counter
    --     self.PC = self.PC + 2
    --     return
    -- end

    -- if lastFourBits == 0x7 then -- 8xy7
    --     if self.registers[y] > self.registers[x] then self.registers[0xF] = 1
    --     else self.registers[0xF] = 0 end
    --     self.registers[x] = self.registers[y] - self.registers[x]
    --     self.PC = self.PC + 2
    --     return
    -- end

    if lastFourBits == 0x7 then -- 8xy7
        -- Set VF to 0 if there is a borrow (if Vy < Vx), else set it to 1
        if self.registers[y] >= self.registers[x] then
            self.registers[0xF] = 1
        else
            self.registers[0xF] = 0
        end
        -- Perform subtraction Vy - Vx and store in Vx, masking to 8 bits
        self.registers[x] = (self.registers[y] - self.registers[x]) & 0xFF
        self.PC = self.PC + 2
        return
    end
    

    if lastFourBits == 0xE then -- 8xyE
        -- Set VF to the most significant bit of reg x (bit 7)
        self.registers[0xF] = (self.registers[x] & 0x80) ~= 0 and 1 or 0  -- Get the MSB of Vx directly
    
        -- Perform the left shift on reg x
        self.registers[x] = (self.registers[x] << 1) & 0xFF  -- Shift left and mask to 8 bits
    
        self.PC = self.PC + 2
        return
    end
    -- end of cases of 0x8xyN
end -- end of function for @decodeEight()

function Cpu:decodeNine(x, y)
    if (self.instruction & 0x000F) == 0x0000 then  -- Ensure last nibble is zero
        if self.registers[x] ~= self.registers[y] then
            self.PC = self.PC + 4 
        else
            self.PC = self.PC + 2
        end
    else
        -- Handle as unknown opcode or skip
        self.PC = self.PC + 2
    end
end

-- function Cpu:decodeNine(x, y) -- 0x9xy0
--     if self.registers[x] ~= self.registers[y] then
--         self.PC = self.PC + 4 
--         return
--     end
--     self.PC = self.PC + 2
-- end

function Cpu:decodeA(nnn)
    self.regI = nnn
    self.PC = self.PC + 2
end

function Cpu:decodeB(nnn)
    self.PC = nnn + self.registers[0]
end

function Cpu:decodeC(x, kk)
    -- Generate a random number between 0 and 255
    local randomValue = math.random(0, 255)

    -- Perform bitwise AND with kk and store the result in Vx
    self.registers[x] = randomValue & kk

    self.PC = self.PC + 2
end

function Cpu:decodeD(nnn, x, y)
    local n = nnn & 0x000F
    local startX = self.registers[x] & 0xFF
    local startY = self.registers[y] & 0xFF
    self.registers[0xF] = 0

    for row = 0, n - 1 do
        local spriteByte = self.memory:readByte(self.regI + row)
        print("Processing sprite byte at row", row, ":", spriteByte)

        for col = 0, 7 do
            local pixelX = (startX + col) % 64
            local pixelY = (startY + row) % 32
            local spritePixel = (spriteByte >> (7 - col)) & 1

            local bufferIndex = pixelY * 64 + pixelX
            local displayPixel = self.memory.displayBuffer[bufferIndex]

            if spritePixel == 1 and displayPixel == 1 then
                self.registers[0xF] = 1
            end

            -- XOR the sprite pixel onto the display buffer
            self.memory.displayBuffer[bufferIndex] = displayPixel ~ spritePixel 
            print("Updated pixel at", bufferIndex, "to:", self.memory.displayBuffer[bufferIndex])

            -- Print the entire display buffer after each pixel update
            print("Current Display Buffer:")
            for i = 1, #self.memory.displayBuffer do
                io.write(self.memory.displayBuffer[i] .. " ")
                -- Print a new line every 64 pixels for readability
                if i % 64 == 0 then io.write("\n") end
            end
            print("\n") -- Separate each update for clarity
        end
    end

    self.PC = self.PC + 2
end



-- function Cpu:decodeD(nnn, x, y)
--     -- Need to implement stil. Is used for writing to screen and stuff 

-- end

function Cpu:decodeE(nnn, x, y, kk)
    -- need to implement key logic eventually 
    self.PC = self.PC + 2
end

function Cpu:decodeF(nnn, x, y, kk)
    local lowerByte = (nnn & 0x00FF)

    if lowerByte == 0x07 then 
        self.registers[x] = self.delayTimer
        self.PC = self.PC + 2
        return
    end

    if lowerByte == 0x0A then 
        -- self.paused = true -- enable this later again once keyboard IO is implemented
        self.PC = self.PC + 2
        return
    end

    if lowerByte == 0x15 then 
        self.delayTimer = self.registers[x]
        self.PC = self.PC + 2
        return
    end

    if lowerByte == 0x18 then 
        self.soundTimer = self.registers[x]
        self.PC = self.PC + 2
        return
    end

    if lowerByte == 0x1E then
        self.regI =  self.regI + self.registers[x]
        self.PC = self.PC + 2
        return
    end

    if lowerByte == 0x29 then 
        self.regI = self.registers[x] * 5
        self.PC = self.PC + 2
        return
    end

    if lowerByte == 0x33 then 
        -- Get the value in Vx and calculate its BCD representation
        local value = self.registers[x] & 0xFF
        local hundreds = math.floor(value / 100)
        local tens = math.floor((value % 100) / 10)
        local ones = value % 10
    
        -- Write each BCD digit to memory using the writeByte method
        self.memory:writeByte(self.regI, hundreds)
        self.memory:writeByte(self.regI + 1, tens)
        self.memory:writeByte(self.regI + 2, ones)
    
        self.PC = self.PC + 2
        return
    end

    if lowerByte == 0x55 then 
        -- Write the values in registers V0 to Vx to memory starting at address regI
        for i = 0, x do
            self.memory:writeByte(self.regI + i, self.registers[i])
        end
        self.PC = self.PC + 2
        return
    end

    if lowerByte == 0x65 then 
        -- Read values from memory starting at address regI to registers V0 to Vx
        for i = 0, x do
            self.registers[i] = self.memory:readByte(self.regI + i)
        end
        self.PC = self.PC + 2
        return
    end


end

return Cpu