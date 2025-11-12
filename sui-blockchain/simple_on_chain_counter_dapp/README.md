# Simple On-Chain Counter DApp

A decentralized counter application built on Sui blockchain where users can create their own personal counters and increment them on-chain.

## Project Overview

This project is the homework assignment for the Sui Bootcamp 2025, demonstrating core Sui Move concepts including:

- Object ownership and management
- Transaction handling
- Event emissions
- Smart contract deployment

## Deployment Information

### Testnet Deployment

```
Package ID: 0xe38bcd438aba76c9da7fcc5d8ce9d86027a0e1c440dd6146cfe33f1da30f25f2
Transaction Hash/Transaction Digest: 3zhMvKZ1R8mhAKRnmzCwBBGAqPsakXeMrWjkyxg4vvi1
Network: Sui Testnet
Module: simple_on_chain_counter_dapp__contract
```

**Sui Explorer Links:**
- **Package**: https://suiscan.xyz/testnet/object/0xe38bcd438aba76c9da7fcc5d8ce9d86027a0e1c440dd6146cfe33f1da30f25f2
- **Transaction**: https://suiscan.xyz/testnet/tx/3zhMvKZ1R8mhAKRnmzCwBBGAqPsakXeMrWjkyxg4vvi1

## Smart Contract Architecture

### Counter Object Structure

```move
public struct Counter has key {
    id: UID,
    owner: address,
    count: u64,
    created_at: u64,
}
```

**Fields:**

- `id`: Unique identifier for the Counter object
- `owner`: Address of the counter owner
- `count`: Current counter value (starts at 0)
- `created_at`: Timestamp when counter was created (in milliseconds)

### Core Functions

1. `create_counter()` - Creates a new Counter object owned by the caller.

```move
public fun create_counter(ctx: &mut TxContext)
```

**Behavior:**

- Initializes counter with value 0
- Sets owner to transaction sender
- Records creation timestamp
- Emits `CounterCreated` event
- Transfers ownership to caller

**Usage:**

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module simple_on_chain_counter_dapp__contract \
  --function create_counter \
  --gas-budget 10000000
```

2. `increment()` - Increases the counter value by 1.

```move
public fun increment(counter: &mut Counter, ctx: &mut TxContext)
```

**Behavior:**

- Verifies caller is the owner
- Checks for overflow
- Increments counter by 1
- Emits `CounterIncremented` event

**Usage:**

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module simple_on_chain_counter_dapp__contract \
  --function increment \
  --args <COUNTER_OBJECT_ID> \
  --gas-budget 10000000
```

3. `get_value()` - Returns the current counter value (read-only).

```move
public fun get_value(counter: &Counter): u64
```

**Additional Accessors:**

- `get_owner(counter: &Counter): address` - Returns counter owner
- `get_created_at(counter: &Counter): u64` - Returns creation timestamp

### Events

#### CounterCreated

```move
public struct CounterCreated has copy, drop {
    counter_id: ID,
    owner: address,
    created_at: u64,
}
```

Emitted when a new counter is created.

#### CounterIncremented

```move
public struct CounterIncremented has copy, drop {
    counter_id: ID,
    old_value: u64,
    new_value: u64,
}
```

Emitted when a counter is incremented.

### Error Handling

```move
const ECounterOverflow: u64 = 0;
```

Protects against:

- Counter overflow (when reaching maximum u64 value)
- Ownership verification

## Build Instructions

### Prerequisites

- [Sui CLI](https://docs.sui.io/guides/developer/getting-started/sui-install) installed
- Sui CLI configured for testnet via `sui client switch --env testnet`

### Build the Contract

```bash
cd simple_on_chain_counter_dapp__contract
sui move build
```

**Expected Output:**

```
INCLUDING DEPENDENCY Sui
INCLUDING DEPENDENCY MoveStdlib
BUILDING simple_on_chain_counter_dapp__contract
```

### Run Tests

```bash
sui move test
```

## Deployment Instructions

### Quick Deployment Steps

1. **Configure Testnet**

```bash
sui client switch --env testnet
```

2. **Get Testnet Tokens**

```bash
sui client faucet
```

- this will prompt you with a URL to visit and get tokens (Eg. `For testnet tokens, please use the Web UI: https://faucet.sui.io/?address=0x34976bbc2682ba1d5a8e9db5ad2ad74ef6a4919c6dc4249c917f9f88bd501a78`)
  2.1 **Check Balance**

```bash
sui client gas
# or
sui client balance
```

3. **Publish Contract**

```bash
cd simple_on_chain_counter_dapp__contract
sui client publish --gas-budget 100000000
# Output will show the Package ID - get it from there and add it to .env file
# OR use
bash scripts.bash publish_contract
```

4. **Save Package ID** from the output

5. **Verify on Explorer**
   - Visit: https://suiscan.xyz/testnet/home
   - Search for your Package ID

### Helpers

- get SUI Client Active Address - `sui client active-address`

## Testing the Deployed Contract

### Create a Counter

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module simple_on_chain_counter_dapp__contract \
  --function create_counter \
  --gas-budget 10000000

# Output will show the Created Objects section and expose the Counter Object ID
# - get it from there and add it to .env file
# OR use
bash scripts.bash create_counter
```

Save the Counter Object ID from the "Created Objects" section.

### Increment Counter

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module simple_on_chain_counter_dapp__contract \
  --function increment \
  --args <COUNTER_OBJECT_ID> \
  --gas-budget 10000000

# OR use
bash scripts.bash increment
```

### Check Counter State

```bash
sui client object <COUNTER_OBJECT_ID>
# OR use
bash scripts.bash check_counter_state
```

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module simple_on_chain_counter_dapp__contract \
  --function get_value \
  --args <COUNTER_OBJECT_ID>

# OR use
bash scripts.bash get_counter_value
```

Look for the `count` field in the output to see the current value.

#### Additional Accessors

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module simple_on_chain_counter_dapp__contract \
  --function get_owner \
  --args <COUNTER_OBJECT_ID>

# OR use
bash scripts.bash get_counter_owner
```

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module simple_on_chain_counter_dapp__contract \
  --function get_created_at \
  --args <COUNTER_OBJECT_ID>

# OR use
bash scripts.bash get_counter_created_at
```

## Implementation Highlights

### Ownership Model

- Each Counter is an owned object (has `key` ability)
- Only the owner can increment their counter
- Ownership is enforced by Sui's object model
- Multiple users can create their own independent counters

### Security Features

- **Overflow Protection**: Checks counter value before incrementing
- **Owner Verification**: Ensures only the owner can modify their counter
- **Type Safety**: Move's type system prevents invalid operations

### Event-Driven Architecture

Events are emitted for:

- Counter creation (tracking new counters)
- Counter increments (tracking value changes)

These events can be monitored off-chain for analytics and UI updates.

## Resources

- **Sui Documentation**: https://docs.sui.io/
- **Sui Move Concepts**: https://docs.sui.io/concepts/sui-move-concepts
- **Sui Testnet Explorer**: https://suiscan.xyz/testnet/home
- **Sui Move Examples**: https://examples.sui.io/
- **Sui Discord**: https://discord.gg/sui

## Assignment Requirements

This project fulfills the following homework requirements:
- Counter object with `key` ability
- Stores owner address, count value, and creation timestamp
- `create_counter()` function to create new counters
- `increment()` function to increase counter value
- `get_value()` function for read-only access
- Proper ownership handling
- Error handling for edge cases
- Event emissions for counter operations
- Deployed to Sui Testnet
- Comprehensive documentation

## Author

Paul Serban

## License

This project is created for educational purposes as part of the Sui Bootcamp 2025 homework assignment.
