#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

PLAY_GAME()
{
  echo Enter your username:
  read USERNAME

  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME'")

  if [[ -z $USER_ID ]]
  then
    INSERT_USER=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE name = '$USERNAME'")
    GAMES_PLAYED=0
    echo Welcome, $USERNAME! It looks like this is your first time here.

  else
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE name = '$USERNAME'")
    BEST_GAME=$($PSQL "SELECT MIN(turn_taken) FROM games WHERE user_id = $USER_ID")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi

  RANDOM_NUMBER=$(( $RANDOM % 1000 + 1))
  echo "Guess the secret number between 1 and 1000:"
  read GUESS
  GUESSES=1
  while (( $RANDOM_NUMBER != $GUESS ))
  do
    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
      read GUESS
    elif [[ $RANDOM_NUMBER -lt $GUESS ]]
    then
      echo "It's lower than that, guess again:"
      read GUESS
      ((GUESSES++))

    elif [[ $RANDOM_NUMBER -gt $GUESS ]]
    then
      echo "It's higher than that, guess again:"
      read GUESS
      ((GUESSES++))
    fi
  done
  GAMES_PLAYED=$((GAMES_PLAYED + 1)) 
  UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE user_id = $USER_ID ")
  INSERT_GAME=$($PSQL "INSERT INTO games(user_id, turn_taken) VALUES($USER_ID, $GUESSES)")
  echo "You guessed it in $GUESSES tries. The secret number was $GUESS. Nice job!"

}

PLAY_GAME