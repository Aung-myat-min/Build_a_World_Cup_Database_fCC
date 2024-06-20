#!/bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE TABLE games, teams")

# Read file
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT W_GOALS O_GOALS
do
  # Skip the header line
  if [[ $YEAR != "year" ]]
  then
    # Check if the team exists or not
    W_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    O_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # If not, create the team
    if [[ -z $W_ID ]]
    then
      INSERT_NEW_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_NEW_TEAM == 'INSERT 0 1' ]]
      then
        echo -e "\nCreated new team: $WINNER\n"
      fi
      W_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    if [[ -z $O_ID ]]
    then
      INSERT_NEW_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_NEW_TEAM == 'INSERT 0 1' ]]
      then
        echo -e "\nCreated new team: $OPPONENT\n"
      fi
      O_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    # Create new game
    INSERT_NEW_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $W_ID, $O_ID, $W_GOALS, $O_GOALS)")
    if [[ $INSERT_NEW_GAME == 'INSERT 0 1' ]]
    then
      echo -e "\nCreated new game: which is participated in $YEAR, ($WINNER VS $OPPONENT)\n"
    fi
  fi
done
