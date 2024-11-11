print("Please enter a number range: ");
local min = io.read("*n");
print("you picked number range of : ",min);
print("Now take a guess pick a number from 0 to "..min);
local userGuess = io.read("*n");
local number = math.random(min);

if userGuess == number then 
    print("You guessed right! The number was: "..number);
    else
    print("You guessed wrong! The number was: "..number);
end
