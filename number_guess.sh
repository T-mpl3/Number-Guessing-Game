#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
NUMBER_TO_GUESS=$(echo $(( $RANDOM % 1000 + 1 )))

echo "Enter your username:"
read USERNAME
USERNAME_RESULT=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")

if [[ $USERNAME_RESULT ]]
then
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
  
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  GAMES_PLAYED=0
  BEST_GAME=0
  NEW_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
fi

GUESSING_GAME() {
  NUMBER_OF_TRIES=1
  echo "Guess the secret number between 1 and 1000:"
  read GUESSED_NUMBER

  while [[ ! $GUESSED_NUMBER -eq $NUMBER_TO_GUESS ]] 
  do
    
    ((NUMBER_OF_TRIES++))
    if [[ $GUESSED_NUMBER =~ [0-9]+ ]]
    then
      if [[ $GUESSED_NUMBER -lt $NUMBER_TO_GUESS ]]
      then
       echo "It's higher than that, guess again:"
      elif [[ $GUESSED_NUMBER -gt $NUMBER_TO_GUESS ]]
      then
        echo "It's lower than that, guess again:"
      fi
    else
     echo "That is not an integer, guess again:"
    fi
    read GUESSED_NUMBER
  done
  if (( 0 == $BEST_GAME || $NUMBER_OF_TRIES < $BEST_GAME ))
  then
    NEW_BEST_RESULT=$($PSQL "UPDATE users SET best_game='$NUMBER_OF_TRIES' WHERE username='$USERNAME'")
  fi
  (( GAMES_PLAYED++ ))
  GAME_COUNT_RESULT=$($PSQL "UPDATE users SET games_played='$GAMES_PLAYED' WHERE username='$USERNAME'")
  echo "You guessed it in $NUMBER_OF_TRIES tries. The secret number was $NUMBER_TO_GUESS. Nice job!"
}

GUESSING_GAME
