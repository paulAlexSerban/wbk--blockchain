# Getting Started w. Sui & Move
> Follow: https://move-book.com

## SUI CLI Walkthrogh
- `sui client` - running for the first time
- `sui client acrtive-address` - shows your default address - public wallet address
- `sui client switch --env testnet` - switch to testnet environment
- `sui client faucet` - will print a link to get test SUI tokens to your wallet
- `sui client gas` - check your gas balance - SUI tokens in your wallet - you will see multiple tokens if you have received multiple faucets
- `sui client balance` - check your balance of all coins in your wallet
  - using `gas` and `balance` are interchangeable, but the `balance` command shows all coin types
- `sui client merge-coin --primary-coin <COIN_ID> --coin-to-merge <COIN_ID>` - merge two coins into one coin
- `sui client split-coin --coin <COIN_ID> --gas-budget <GAS_BUDGET> --amount <AMOUNT>` - split a coin into two coins