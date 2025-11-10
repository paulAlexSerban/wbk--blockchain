# Guestbook Smart Contract Documentation

## Overview
This is a **Sui Move smart contract** that implements a simple guestbook application on the Sui blockchain. It allows users to write and store messages permanently on-chain, similar to a digital guestbook you might find at a website or event.

## Key Concepts

### What is Move?
Move is a programming language designed for writing smart contracts on blockchain platforms like Sui. It emphasizes **safety** and **resource management**.

### Abilities in Move
- `store`: Allows a struct to be stored inside other structs
- `key`: Allows a struct to be owned and transferred (makes it a Sui object)

## Contract Structure

### 1. **Constants**
```move
const MAX_MESSAGE_LENGTH: u64 = 280;
```
- Limits messages to 280 characters (Twitter-style)
- Prevents spam and excessive storage usage

### 2. **Message Struct**
```move
public struct Message has store {
    content: vector<u8>,  // Message as byte array
    author: address,      // Who wrote it
}
```
- Represents a single guestbook entry
- `has store`: Can be stored inside the Guestbook
- Stores the message content and author's blockchain address

### 3. **Guestbook Struct**
```move
public struct Guestbook has key {
    id: object::UID,           // Unique ID
    messages: vector<Message>, // All messages
    no_of_messages: u64,      // Message count
}
```
- The main container for all messages
- `has key`: Makes it a Sui object that can be shared
- Uses a dynamic array (`vector`) to store messages

## Functions

### 📝 **init(ctx: &mut TxContext)**
**Purpose**: Initialization function (runs once when deployed)

**What it does**:
1. Creates a new empty Guestbook
2. Gives it a unique ID
3. Makes it a **shared object** (anyone can interact with it)

```move
fun init(ctx: &mut TxContext) {
    let guestbook = Guestbook {
        id: object::new(ctx),
        messages: vector::empty<Message>(),
        no_of_messages: 0,
    };
    sui::transfer::share_object(guestbook);
}
```

### ✍️ **create_message(content, ctx): Message**
**Purpose**: Creates and validates a new message

**What it does**:
1. Checks message length ≤ 280 characters
2. Gets sender's address from transaction context
3. Returns a validated Message struct

**Why separate creation?**: This pattern allows for validation before committing to storage

### 📮 **post_message(message, guestbook)**
**Purpose**: Adds a message to the guestbook

**What it does**:
1. Appends the message to the messages vector
2. Increments the message counter

**Parameters**:
- `message`: A pre-created Message
- `guestbook: &mut Guestbook`: Mutable reference to the shared guestbook

## How Users Interact

### Typical Flow:
1. **User creates a message**: `create_message("Hello!", ctx)` → validates & returns Message
2. **User posts the message**: `post_message(message, guestbook)` → stores on-chain
3. **Message is permanently stored** in the shared Guestbook object

## Key Design Decisions

### ✅ Shared Object Pattern
```move
sui::transfer::share_object(guestbook);
```
- Makes the guestbook accessible to **all users**
- Multiple people can write messages concurrently
- No single owner controls it

### ✅ Two-Step Process (Create → Post)
- **Separation of concerns**: Validation separate from storage
- **Flexibility**: Can create message and post later
- **Gas efficiency**: Can batch operations

### ✅ Length Validation
```move
assert!(content.length() <= MAX_MESSAGE_LENGTH, 1);
```
- Prevents abuse and excessive storage costs
- Aborts transaction if validation fails (error code: 1)

## Security Features

1. **Length constraints** prevent spam
2. **Author tracking** via `ctx.sender()` prevents impersonation
3. **Immutable messages** (no delete/edit functions)
4. **Type safety** via Move's strict type system

## Example Usage (Pseudocode)

```typescript
// User A writes a message
let msg = create_message("Welcome to my guestbook!", tx_context);
post_message(msg, shared_guestbook);

// User B writes a message
let msg2 = create_message("Thanks for visiting!", tx_context);
post_message(msg2, shared_guestbook);

// Both messages are now permanently stored on-chain
```

## Potential Improvements

1. **Add message retrieval function** (currently write-only)
2. **Add timestamps** to messages
3. **Implement pagination** for large guestbooks
4. **Add moderation capabilities** (owner-only delete)
5. **Emit events** when messages are posted

This contract demonstrates fundamental Sui Move concepts: shared objects, struct composition, validation patterns, and basic access control.