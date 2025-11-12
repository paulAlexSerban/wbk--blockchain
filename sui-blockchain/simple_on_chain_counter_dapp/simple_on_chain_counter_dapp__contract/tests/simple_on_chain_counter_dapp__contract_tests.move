#[test_only]
module simple_on_chain_counter_dapp__contract::simple_on_chain_counter_dapp__contract_tests;

use simple_on_chain_counter_dapp__contract::simple_on_chain_counter_dapp__contract::{
    Self,
    Counter,
};
use sui::test_scenario::{Self as ts, Scenario};
use sui::test_utils;

// Test addresses
const OWNER: address = @0xA;
const OTHER_USER: address = @0xB;

// ===== Helper Functions =====

fun setup_test(): Scenario {
    ts::begin(OWNER)
}

// ===== Test Cases =====

#[test]
/// Test creating a new counter
fun test_create_counter() {
    let mut scenario = setup_test();
    
    // Create a counter
    ts::next_tx(&mut scenario, OWNER);
    {
        simple_on_chain_counter_dapp__contract::create_counter(ts::ctx(&mut scenario));
    };
    
    // Verify counter was created and transferred to owner
    ts::next_tx(&mut scenario, OWNER);
    {
        let counter = ts::take_from_sender<Counter>(&scenario);
        
        // Verify initial values
        assert!(simple_on_chain_counter_dapp__contract::get_value(&counter) == 0, 0);
        assert!(simple_on_chain_counter_dapp__contract::get_owner(&counter) == OWNER, 1);
        assert!(simple_on_chain_counter_dapp__contract::get_created_at(&counter) > 0, 2);
        
        ts::return_to_sender(&scenario, counter);
    };
    
    ts::end(scenario);
}

#[test]
/// Test incrementing a counter once
fun test_increment_counter() {
    let mut scenario = setup_test();
    
    // Create a counter
    ts::next_tx(&mut scenario, OWNER);
    {
        simple_on_chain_counter_dapp__contract::create_counter(ts::ctx(&mut scenario));
    };
    
    // Increment the counter
    ts::next_tx(&mut scenario, OWNER);
    {
        let mut counter = ts::take_from_sender<Counter>(&scenario);
        simple_on_chain_counter_dapp__contract::increment(&mut counter, ts::ctx(&mut scenario));
        
        // Verify counter was incremented
        assert!(simple_on_chain_counter_dapp__contract::get_value(&counter) == 1, 0);
        
        ts::return_to_sender(&scenario, counter);
    };
    
    ts::end(scenario);
}

#[test]
/// Test incrementing a counter multiple times
fun test_multiple_increments() {
    let mut scenario = setup_test();
    
    // Create a counter
    ts::next_tx(&mut scenario, OWNER);
    {
        simple_on_chain_counter_dapp__contract::create_counter(ts::ctx(&mut scenario));
    };
    
    // Increment the counter 5 times
    ts::next_tx(&mut scenario, OWNER);
    {
        let mut counter = ts::take_from_sender<Counter>(&scenario);
        
        simple_on_chain_counter_dapp__contract::increment(&mut counter, ts::ctx(&mut scenario));
        simple_on_chain_counter_dapp__contract::increment(&mut counter, ts::ctx(&mut scenario));
        simple_on_chain_counter_dapp__contract::increment(&mut counter, ts::ctx(&mut scenario));
        simple_on_chain_counter_dapp__contract::increment(&mut counter, ts::ctx(&mut scenario));
        simple_on_chain_counter_dapp__contract::increment(&mut counter, ts::ctx(&mut scenario));
        
        // Verify counter value
        assert!(simple_on_chain_counter_dapp__contract::get_value(&counter) == 5, 0);
        
        ts::return_to_sender(&scenario, counter);
    };
    
    ts::end(scenario);
}

#[test]
/// Test that multiple users can create their own counters
fun test_multiple_counters() {
    let mut scenario = setup_test();
    
    // OWNER creates a counter
    ts::next_tx(&mut scenario, OWNER);
    {
        simple_on_chain_counter_dapp__contract::create_counter(ts::ctx(&mut scenario));
    };
    
    // OTHER_USER creates a counter
    ts::next_tx(&mut scenario, OTHER_USER);
    {
        simple_on_chain_counter_dapp__contract::create_counter(ts::ctx(&mut scenario));
    };
    
    // Verify OWNER's counter
    ts::next_tx(&mut scenario, OWNER);
    {
        let mut counter = ts::take_from_sender<Counter>(&scenario);
        simple_on_chain_counter_dapp__contract::increment(&mut counter, ts::ctx(&mut scenario));
        assert!(simple_on_chain_counter_dapp__contract::get_value(&counter) == 1, 0);
        assert!(simple_on_chain_counter_dapp__contract::get_owner(&counter) == OWNER, 1);
        ts::return_to_sender(&scenario, counter);
    };
    
    // Verify OTHER_USER's counter
    ts::next_tx(&mut scenario, OTHER_USER);
    {
        let mut counter = ts::take_from_sender<Counter>(&scenario);
        simple_on_chain_counter_dapp__contract::increment(&mut counter, ts::ctx(&mut scenario));
        simple_on_chain_counter_dapp__contract::increment(&mut counter, ts::ctx(&mut scenario));
        assert!(simple_on_chain_counter_dapp__contract::get_value(&counter) == 2, 2);
        assert!(simple_on_chain_counter_dapp__contract::get_owner(&counter) == OTHER_USER, 3);
        ts::return_to_sender(&scenario, counter);
    };
    
    ts::end(scenario);
}

#[test]
/// Test get_value returns correct value
fun test_get_value() {
    let mut scenario = setup_test();
    
    // Create and increment counter
    ts::next_tx(&mut scenario, OWNER);
    {
        simple_on_chain_counter_dapp__contract::create_counter(ts::ctx(&mut scenario));
    };
    
    ts::next_tx(&mut scenario, OWNER);
    {
        let mut counter = ts::take_from_sender<Counter>(&scenario);
        
        // Initial value should be 0
        assert!(simple_on_chain_counter_dapp__contract::get_value(&counter) == 0, 0);
        
        // Increment and check again
        simple_on_chain_counter_dapp__contract::increment(&mut counter, ts::ctx(&mut scenario));
        assert!(simple_on_chain_counter_dapp__contract::get_value(&counter) == 1, 1);
        
        ts::return_to_sender(&scenario, counter);
    };
    
    ts::end(scenario);
}
