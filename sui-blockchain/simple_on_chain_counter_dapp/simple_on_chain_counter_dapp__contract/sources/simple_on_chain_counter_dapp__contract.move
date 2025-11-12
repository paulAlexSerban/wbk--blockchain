/// Module: simple_on_chain_counter_dapp__contract
/// A simple on-chain counter DApp that allows users to create and increment their own counters
module simple_on_chain_counter_dapp__contract::simple_on_chain_counter_dapp__contract;

// For Move coding conventions, see
// https://docs.sui.io/concepts/sui-move-concepts/conventions

use sui::event;

// ===== Error Codes =====

/// Error code for when trying to increment counter causes overflow
const ECounterOverflow: u64 = 0;

// ===== Structs =====

/// Counter object that stores the owner, count value, and creation timestamp
public struct Counter has key {
    id: UID,
    owner: address,
    count: u64,
    created_at: u64,
}

// ===== Events =====

/// Event emitted when a new counter is created
public struct CounterCreated has copy, drop {
    counter_id: ID,
    owner: address,
    created_at: u64,
}

/// Event emitted when a counter is incremented
public struct CounterIncremented has copy, drop {
    counter_id: ID,
    old_value: u64,
    new_value: u64,
}

// ===== Public Functions =====

/// Creates a new Counter object owned by the caller
/// The counter starts at 0 and records the creation timestamp
public fun create_counter(ctx: &mut TxContext) {
    let sender = ctx.sender();
    let created_at = ctx.epoch_timestamp_ms();
    
    let counter = Counter {
        id: object::new(ctx),
        owner: sender,
        count: 0,
        created_at,
    };
    
    let counter_id = object::id(&counter);
    
    // Emit counter created event
    event::emit(CounterCreated {
        counter_id,
        owner: sender,
        created_at,
    });
    
    // Transfer ownership to the caller
    transfer::transfer(counter, sender);
}

/// Increments the counter value by 1
/// Only the owner can increment their counter
public fun increment(counter: &mut Counter, ctx: &mut TxContext) {
    // Verify ownership (automatically enforced by Sui's ownership model)
    let sender = ctx.sender();
    assert!(counter.owner == sender, ECounterOverflow);
    
    let old_value = counter.count;
    
    // Check for overflow before incrementing
    assert!(counter.count < 18446744073709551615, ECounterOverflow);
    
    counter.count = counter.count + 1;
    let new_value = counter.count;
    
    // Emit counter incremented event
    event::emit(CounterIncremented {
        counter_id: object::id(counter),
        old_value,
        new_value,
    });
}

/// Returns the current counter value (read-only)
public fun get_value(counter: &Counter): u64 {
    counter.count
}

/// Returns the counter owner (read-only)
public fun get_owner(counter: &Counter): address {
    counter.owner
}

/// Returns the counter creation timestamp (read-only)
public fun get_created_at(counter: &Counter): u64 {
    counter.created_at
}

// ===== Test Functions =====

#[test_only]
public fun test_init(_ctx: &mut TxContext) {
    // Test initialization function
}

#[test_only]
public fun get_count_for_testing(counter: &Counter): u64 {
    counter.count
}


