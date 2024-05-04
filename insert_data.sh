#! /bin/bash

if [[ $1 == "test" ]]; then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $(${PSQL} "TRUNCATE teams, games")

cat games.csv | while IFS="," read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS; do
  if [[ $YEAR = 'year' ]]; then
    continue
  fi

  WINNER_EXISTS=$(${PSQL} "SELECT name FROM teams WHERE name = '${WINNER}' ")
  OPPONENT_EXISTS=$(${PSQL} "SELECT name FROM teams WHERE name = '${OPPONENT}' ")

  if [[ -z $WINNER_EXISTS ]]; then
    INSERT_RESULT=$(${PSQL} "INSERT INTO teams(name) VALUES('${WINNER}') ")
  fi

  if [[ -z $OPPONENT_EXISTS ]]; then
    INSERT_RESULT=$(${PSQL} "INSERT INTO teams(name) VALUES('${OPPONENT}') ")
  fi

  WINNER_ID=$(${PSQL} "SELECT team_id FROM teams WHERE name = '${WINNER}' ")
  OPPONENT_ID=$(${PSQL} "SELECT team_id FROM teams WHERE name = '${OPPONENT}' ")

  echo $WINNER_ID
  echo $OPPONENT_ID

  GAME_EXISTS=$(${PSQL} "SELECT game_id FROM games WHERE year = ${YEAR} AND round = '${ROUND}' AND winner_id = ${WINNER_ID} AND opponent_id = ${OPPONENT_ID} ")
  if [[ -z $GAME_EXISTS ]]; then
    INSERT_RESULT=$(${PSQL} "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS) ")
    echo $INSERT_RESULT
  fi

done
