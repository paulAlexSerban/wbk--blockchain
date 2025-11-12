#!/bin/bash
# makes sure the folder containing the script will be the root folder
cd "$(dirname "$0")" || exit

source ../.env

echo "PACKAGE_ID=$PACKAGE_ID"

# if you have sui installed in root/sui_main/sui
SUI_BIN=~/sui_main/sui
# # if you have sui installed via cargo - uncomment below
# SUI_BIN=$HOME/.cargo/bin/sui
# # if you have sui installed via suiup - uncomment below
# SUI_BIN=$HOME/.sui/sui/bin/sui
# # if you have sui installed via homebrew - uncomment below
# SUI_BIN=/opt/homebrew/bin/sui

function create_env_file_if_not_exists() {
  if [ ! -f ../.env ]; then
    echo ".env file not found, creating one..."
    touch ../.env

    echo "MODULE_NAME=simple_on_chain_counter_dapp__contract" >> ../.env
    echo "PACKAGE_ID=" >> ../.env
    echo "COUNTER_OBJECT_ID=" >> ../.env
  fi
  echo ".env file is ready."
}


if [ ! -f "$SUI_BIN" ]; then
    echo "Error: sui binary not found at $SUI_BIN"
    echo "Please update SUI_BIN variable in this script"
    exit 1
fi

function publish_contract() {
  echo "Publishing contract..."
  local OUTPUT=$($SUI_BIN client publish --gas-budget 100000000 2>&1)
  echo "$OUTPUT"
  
  local PACKAGE_ID=$(echo "$OUTPUT" | grep -oE 'PackageID: 0x[a-f0-9]+' | awk '{print $2}')
  
  if [ -n "$PACKAGE_ID" ]; then
    echo ""
    echo " [ SUCCESS ] Published package with ID: $PACKAGE_ID"
    echo ""
    echo "Add this to your .env file:"
    echo "PACKAGE_ID=$PACKAGE_ID"
    sed -i'' -e "s/^PACKAGE_ID=.*/PACKAGE_ID=$PACKAGE_ID/" ../.env
  else
    echo " [ ERROR ] Failed to extract Package ID from output"
    exit 1
  fi
}

function create_counter() {
  OUTPUT=$($SUI_BIN client call --package $PACKAGE_ID \
    --module $MODULE_NAME \
    --function create_counter \
    --gas-budget 10000000)

  echo "$OUTPUT"
  COUNTER_OBJECT_ID=$(echo "$OUTPUT" | grep -oE 'counter_id │ 0x[a-f0-9]+' | awk '{print $3}')
  sed -i'' -e "s/^COUNTER_OBJECT_ID=.*/COUNTER_OBJECT_ID=$COUNTER_OBJECT_ID/" ../.env
}

function increment() {
  OUTPUT=$($SUI_BIN client call --package $PACKAGE_ID \
    --module $MODULE_NAME \
    --function increment \
    --args $COUNTER_OBJECT_ID \
    --gas-budget 10000000)

  echo "$OUTPUT"
}

function check_counter_state() {
  OUTPUT=$($SUI_BIN client object $COUNTER_OBJECT_ID)
  echo "$OUTPUT"
}

function get_counter_value() {
  OUTPUT=$($SUI_BIN client call --package $PACKAGE_ID \
    --module $MODULE_NAME \
    --function get_value \
    --args $COUNTER_OBJECT_ID)

  echo "$OUTPUT"
}

function get_counter_owner() {
  OUTPUT=$($SUI_BIN client call --package $PACKAGE_ID \
    --module $MODULE_NAME \
    --function get_owner \
    --args $COUNTER_OBJECT_ID)

  echo "$OUTPUT"
}

function get_counter_created_at() {
  OUTPUT=$($SUI_BIN client call --package $PACKAGE_ID \
    --module $MODULE_NAME \
    --function get_created_at \
    --args $COUNTER_OBJECT_ID)

  echo "$OUTPUT"
}

create_env_file_if_not_exists
$1