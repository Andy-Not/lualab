These two python files are only for the GUI of the Chip-8 interface.

All of the actual logic of the emulator is written in Lua. Unfortunately, 
I found out after writing the entire emulator that there is not a Lua supported graphics 
library that supports Lua 5.3+ which is needed for it's binary operands to work. 