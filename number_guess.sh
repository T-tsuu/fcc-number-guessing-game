#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

TRIES=0
NUMBER=$(( RANDOM % 1000 + 1 ))
