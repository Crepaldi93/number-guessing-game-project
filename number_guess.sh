#!/bin/bash

# Create variable to query the database
PSQL="psql -X --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate random number
RANDOM_NUMBER="$(($RANDOM % 1000 + 1))"

# Ask user to input username and save it as a variable
echo "Enter your username:"
read USERNAME

# Get player id
PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username = '$USERNAME'")
echo $PLAYER_ID

# If username is not in the database
if  [[ -z $PLAYER_ID ]]
then
  # Display welcome message for new player
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
   # Get player information
  GAMES=$($PSQL "SELECT COUNT(*) FROM games WHERE player_id = $PLAYER_ID")
  echo $GAMES
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE player_id = $PLAYER_ID")
  echo $BEST_GAME

  # Display welcome message for registered player
  echo "Welcome back, $USERNAME! You have played $GAMES games, and your best game took $BEST_GAME guesses."
fi

# Display message for first guess and get input
echo "Guess the secret number between 1 and 1000:"
read GUESS

# Set initial number of guesses to 1
GUESSES=1

# Check input and ask for new guess until it is correct
until [[ $GUESS == $RANDOM_NUMBER ]]
do
  # If guess is not an integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    # Ask for new guess
    echo "That is not an integer, guess again:"
  # If guess is higher than random number
  elif [[ $GUESS > $RANDOM_NUMBER ]]
  then
    # Ask for new guess
    echo "It's lower than that, guess again:"
  # If guess is lower than random number
  elif [[ $GUESS < $RANDOM_NUMBER ]]
  then
    # Ask for new guess
    echo "It's higher than that, guess again:"
  fi

  # Read input for new guess
  read GUESS

  # Increment number of guesses by 1
  ((GUESSES++))
done

echo "You guessed it in $GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!"

# If player is new
if [[ -z $PLAYER_ID ]]
then
  # Add player to the database
  ADD_PLAYER_RESULT=$($PSQL "INSERT INTO players(username) VALUES('$USERNAME')")

  # Get new player id
  PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username = '$USERNAME'")
fi

# Add game to the database
ADD_GAME_RESULT=$($PSQL "INSERT INTO games(player_id, guesses) VALUES($PLAYER_ID, $GUESSES)")