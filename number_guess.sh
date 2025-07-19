#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Enter your username:"
read NAME

USER_INFO=$($PSQL "SELECT user_id, username, games_played FROM users WHERE username='$NAME'")

if [[ -z $USER_INFO ]]
then
  echo "Welcome, $NAME! It looks like this is your first time here."
  INSERT_NEW_USER=$($PSQL "INSERT INTO users(username, games_played) VALUES('$NAME', 0)")
  USER_INFO=$($PSQL "SELECT user_id, username, games_played FROM users WHERE username='$NAME'")
  IFS='|' read USERID USERNAME GAMESPLAYED <<< "$USER_INFO"
else
  IFS='|' read USERID USERNAME GAMESPLAYED <<< "$USER_INFO"
  BESTGAME=$($PSQL "SELECT MIN(guesses_amount) FROM games WHERE player_id=$USERID")
  if [[ -z $BESTGAME ]]
  then
    BESTGAME=0
  fi
  echo "Welcome back, $USERNAME! You have played $GAMESPLAYED games, and your best game took $BESTGAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS
while [[ ! $GUESS =~ ^[0-9]+$ ]]
do
  echo "That is not an integer, guess again:"
  read GUESS
done
TRIES=1

while [[ $GUESS != $NUMBER ]]
do
  if [[ $GUESS -gt $NUMBER ]]
  then
    echo -e "\nIt's lower than that, guess again:"
  else
    echo -e "\nIt's higher than that, guess again:"
  fi

  read GUESS
  while [[ ! $GUESS =~ ^[0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
    read GUESS
  done
  ((TRIES++))
done


INSERT_GAME=$($PSQL "INSERT INTO games(player_id, guesses_amount) VALUES($USERID, $TRIES)")
UPDATE_USER=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE user_id=$USERID")
echo "You guessed it in $TRIES tries. The secret number was $NUMBER. Nice job!"