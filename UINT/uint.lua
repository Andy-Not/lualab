-- Define the Uint module for converting values
-- to bytes or shorts. 
Uint = {}

-- Static function to constrain a value to a byte (8 bits)
function Uint.toByte(value)
    return value & 0xFF -- Mask to 8 bits (range: 0 to 255)
end

-- Static function to constrain a value to a short (16 bits)
function Uint.toShort(value)
    return value & 0xFFFF -- Mask to 16 bits (range: 0 to 65535)
end

return Uint