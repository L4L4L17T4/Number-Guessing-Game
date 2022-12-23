#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

DISPLAY() {
  echo -e "\n~~~~~ Number Guessing Game ~~~~~\n" 

  echo "Enter your username: "
  read USERNAME

  #if username in db
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

  #if new username
  if [[  -z $USER_ID  ]]
    then
      echo "Welcome, $USERNAME! It looks like this is your first time here."
      INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
      USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
      
    else
      #get games played
      GAMES_PLAYED=$($PSQL "SELECT COUNT(user_id) FROM games WHERE user_id = '$USER_ID'")

      #get best game (guess)
      BEST_GUESS=$($PSQL "SELECT MIN(attemps) FROM games WHERE user_id = $USER_ID")
      echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GUESS guesses."

  fi

  GAME
}

GAME() {
  #secret number to guess correctly
  SECRET_NUM=$((1 + $RANDOM % 1000))

  #How many attemp
  ATTEMPS=0

  #controller
  CON=0 

  echo "Guess the secret number between 1 and 1000:"

    while  [[ $CON = 0 ]]
    do
    read GUESS

    #if not a number
    if [[  ! $GUESS =~ ^[0-9]+$  ]] 
      then
        echo "That is not an integer, guess again:"
    #if correct guess 
    elif [[ $SECRET_NUM -eq $GUESS ]]
      then
        ATTEMPS=$(($ATTEMPS + 1))
        echo  "You guessed it in $ATTEMPS tries. The secret number was $SECRET_NUM. Nice job!"
        
        #Insert into db
        INSERT_TO_GAMES=$($PSQL "INSERT INTO games(user_id, attemps) VALUES($USER_ID, $ATTEMPS)")
        CON=1
        
    #if greater
    elif [[ $SECRET_NUM -gt $GUESS ]]
      then
        ATTEMPS=$(($ATTEMPS + 1))
        echo -e "\nIt's higher than that, guess again:"
    #if smaller
    else
      ATTEMPS=$(($ATTEMPS + 1))
      echo -e "\nIt's lower than that, guess again:"

    fi    
    done  
}

DISPLAY

