#!/bin/bash
source .env.local

function start_local_network() {
    RUST_LOG="off,sui_node=info" sui start --with-faucet --force-regenesis
}

function setup-new-env-net() {
    sui client new-env --alias localnet --env http://0.0.0.0:9000
}

function list-envs() {
    sui client envs
}

function switch-localnet-env() {
    sui client switch --env localnet
    sui client active-env
}

function switch-testnet-env() {
    sui client switch --env testnet
    sui client active-env
}

function create-new-account() {
    sui client new-address ed25519 test-account-$(date +%s) >> localnet-accounts.md
}

function switch-account() {
    sui client switch --address $ACTIVE_ADDRESS_PUBLIC_KEY
}

function active-account() {
    sui client active-address
}

function list-accounts() {
    sui client addresses
}


function get-local-sui-provate-key() {
    cat ~/.sui/sui_config/sui.keystore
}

function convert-provate-key() {
    sui keytool convert $ACTIVE_ADDRESS_PRIVATE_KEY > private-key.txt
}


function get-gas-balance() {
    sui client gas > gas-balance.txt
}

function debit-gas() {
    sui client faucet
}

function delete-account() {
    # delete account by public key
    sui client delete-address $ACTIVE_ADDRESS_PUBLIC_KEY
}

function build-package() {
    sui move build
}

function publish-package() {
    sui move publish --gas-budget 1000000000 > publish-output.txt
}

$1