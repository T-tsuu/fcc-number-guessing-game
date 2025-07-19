#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

TRIES=0
NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Enter your username:"
read NAME

USER_INFO=$($PSQL "SELECT * FROM users WHERE username='$NAME'")

if [[ -z $USER_INFO ]]
then
  echo "Welcome, $NAME! It looks like this is your first time here."
  INSERT_NEW_USER=$($PSQL "INSERT INTO users(username, games_played) VALUES('$NAME', 0)")
else
  IFS='|' read USERID USERNAME GAMESPLAYED <<< "$USER_INFO"
  BESTGAME=$($PSQL "SELECT MIN(guesses_amount) FROM games WHERE player_id=$USERID")
  echo "Welcome back, $NAME! You have played $GAMESPLAYED games, and your best game took $BESTGAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS

while [[ ! $GUESS =~ ^[0-9]+$ ]]
do
  echo "That is not an integer, guess again:"
  read GUESS
done

while [[ $GUESS != $NUMBER ]]
do
  ((TRIES++))
  if [[ $GUESS > $NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    read GUESS
  else
    echo "It's lower than that, guess again:"
    read GUESS
  fi
done

echo "You guessed it in $TRIES tries. The secret number was $NUMBER. Nice job!"

