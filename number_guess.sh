#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "Enter your username:"
read USERNAME

USER_ID_RESULT=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")


if [[ -z $USER_ID_RESULT ]]
  then
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.\n"
    INSERT_USERNAME_RESULT=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
    
  else
    
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME';")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME';")

    echo Welcome back, $USERNAME\! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
fi


SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

GUESS_COUNT=0

echo "Guess the secret number between 1 and 1000:"
read USER_GUESS


until [[ $USER_GUESS == $SECRET_NUMBER ]]
do
  
  if [[ ! $USER_GUESS =~ ^[0-9]+$ ]]
    then
      echo -e "\nThat is not an integer, guess again:"
      read USER_GUESS
      ((GUESS_COUNT++))
    
    else
      if [[ $USER_GUESS < $SECRET_NUMBER ]]
        then
          echo "It's higher than that, guess again:"
          read USER_GUESS
          ((GUESS_COUNT++))
        else 
          echo "It's lower than that, guess again:"
          read USER_GUESS
          ((GUESS_COUNT++))
      fi  
  fi

done

((GUESS_COUNT++))

USER_ID_RESULT=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
GAMES_PLAYED=$GAMES_PLAYED+1
if [[ $BEST_GAME < $GUESS_COUNT ]]
then
  INSERT_GAME_RESULT=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED, best_game = $GUESS_COUNT WHERE username='$USERNAME';")
else
  INSERT_GAME_RESULT=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE username='$USERNAME';")
fi

echo You guessed it in $GUESS_COUNT tries. The secret number was $SECRET_NUMBER. Nice job!
