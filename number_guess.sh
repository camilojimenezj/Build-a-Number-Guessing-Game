#! /bin/bash
# Number Guessing Game. Guess the random number from 1 to 1000
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo -e "\n~~~~~ Welcome to the Number Guessing Game ~~~~~"

# Ask for username
echo -e "\nEnter your username:\n"
read USERNAME

# Check username in database
GAMES_RESULT=$($PSQL "SELECT games FROM players WHERE username='$USERNAME'")
NEW_PLAYER=false 

# if username is not in database 
if [[ -z $GAMES_RESULT ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  NEW_PLAYER=true
else
  BEST_GAME=$($PSQL "SELECT best_score FROM players WHERE username='$USERNAME'")
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_RESULT games, and your best game took $BEST_GAME guesses."
fi

# Generate random number
NUMBER=$(( RANDOM % 1000 ))

# Game function 
NUMBER_GUESS() {
  echo -e "\n$1\n"
  # Ask for a number
  read PLAYER_TRY
  # if not a number
  if [[ ! $PLAYER_TRY =~ ^[0-9]+$ ]]
  then
    NUMBER_GUESS "That is not an integer, guess again:"
  fi
  # Counter of tries 
  COUNT=$(( $COUNT + 1 ))
  # Compare try with random number
  if (( $PLAYER_TRY == $NUMBER ))
  then
    echo -e "You guessed it in $COUNT tries. The secret number was $NUMBER. Nice job!\n"
    # Add game results to data base
    # If is a new player
    if [[ $NEW_PLAYER = true ]]
    then
      INSERT_NEW_PLAYER=$($PSQL "INSERT INTO players(username, games, best_score) VALUES('$USERNAME', 1, $COUNT)")
    else
      # Compare current score with data base 
      GAMES_COUNT=$(( $GAMES_RESULT + 1 ))
      if [[ $COUNT < $BEST_GAME ]]
      then
        UPDATE_PLAYER=$($PSQL "UPDATE players SET games=$GAMES_COUNT, best_score=$COUNT WHERE username='$USERNAME'")
      else
        UPDATE_PLAYER=$($PSQL "UPDATE players SET games=$GAMES_COUNT WHERE username='$USERNAME'")
      fi
    fi

  elif (( $PLAYER_TRY > $NUMBER ))
  then
    NUMBER_GUESS "It's lower than that, guess again:"
  else
    NUMBER_GUESS "It's higher than that, guess again:"
  fi 
}

# Run the game 
NUMBER_GUESS "Guess the secret number between 1 and 1000:"