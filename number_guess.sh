#!/bin/bash

#PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
PSQL="psql -X --username=freecodecamp --dbname=postgres --tuples-only -c"

NUMBER=$(( RANDOM%1000 +1 )) 

echo -e "Enter your username:"
read USERNAME

NAME=$($PSQL "SELECT name FROM users WHERE name = '$USERNAME'")

if [[ -z $NAME ]]
then
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
  INSERTUSER=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
  NAME=$USERNAME
else
  NAME=$(echo $NAME | sed -E 's/^ *| *$//g')
  GAMES_PLAYED=$($PSQL "select played from users where name = '$NAME'")
  GAMES_PLAYED=$(echo $GAMES_PLAYED | sed -E 's/^ *| *$//g')
  BEST_GAME=$($PSQL "select best from users where name = '$NAME'")
  BEST_GAME=$(echo $BEST_GAME | sed -E 's/^ *| *$//g')
  echo -e "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
GUESS=0

while [[ $INPUT -ne $NUMBER ]]
do
  read INPUT
  while [[ ! $INPUT =~ ^[0-9]+$ ]]
  do
    echo "That is not an integer, guess again:"
    read INPUT
  done
  ((GUESS++))


  if [[ $INPUT -gt $NUMBER ]]
  then
    echo "It's lower than that, guess again:" 
  elif [[ $INPUT -lt $NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    
  fi
  
done

((GAMES_PLAYED++))
UPDATEGAMES=$($PSQL "UPDATE users SET played = $GAMES_PLAYED WHERE name = '$USERNAME'")
if [[ $GUESS -lt $BEST_GAME ]]
then
  UPDATEBEST=$($PSQL "UPDATE users SET best = $GUESS WHERE name = '$USERNAME'")
elif [[ -z $BEST_GAME ]]
then
  UPDATEBEST=$($PSQL "UPDATE users SET best = $GUESS WHERE name = '$USERNAME'")
fi

echo -e "You guessed it in $(echo $GUESS | sed -E 's/^ *| *$//g') tries. The secret number was $(echo $NUMBER | sed -E 's/^ *| *$//g'). Nice job!\n"






