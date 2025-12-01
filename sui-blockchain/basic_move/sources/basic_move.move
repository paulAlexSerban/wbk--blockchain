module basic_move::basic_move;

use std::string::String;
use sui::test_scenario;
use sui::test_utils::destroy;

public struct Hero has key, store {
    id: object::UID, // The unique identifier for the `Hero` object.
    name: String, // The name of the hero, represented as a vector of bytes.
}

public struct Weapon has store {
    power: u8,
}

// Define a public structure `InsignificantWeapon` with `drop` and `store` abilities.
// `drop` allows the structure to be destroyed when it goes out of scope.
// `store` allows the structure to be stored in global storage.
public struct InsignificantWeapon has drop, store {
    power: u8, // The power level of the weapon, represented as an unsigned 8-bit integer.
}

// Public function to mint a new `Hero` object.
// Takes a mutable reference to the transaction context (`TxContext`) as input.
// Returns a new `Hero` object with a unique identifier.
public fun mint_hero(name: String, ctx: &mut TxContext): Hero {
    let hero = Hero { name, id: object::new(ctx) }; // Create a new `Hero` with a unique ID.
    hero // Return the newly created `Hero` object.
}

// Public function to create an `InsignificantWeapon` object.
// Takes the power level (`u8`) as input.
// Returns a new `InsignificantWeapon` object with the specified power level.
public fun create_insignificant_weapon(power: u8): InsignificantWeapon {
    InsignificantWeapon { power } // Return a new `InsignificantWeapon` with the given power.
}

public fun create_weapon(power: u8): Weapon {
    Weapon { power }
}

// Test function to test the `mint_hero` functionality.
// Currently, this function is empty and needs implementation.
#[test]
fun test_mint() {
    let name = b"HeroName".to_string(); // Example name for the hero.
    let mut test = test_scenario::begin(@cafe);
    let hero = mint_hero(name, test.ctx());
    assert!(hero.name == b"HeroName".to_string());
    destroy(hero);
    test.end();
}

// Test function to test the drop semantics of `InsignificantWeapon`.
// Currently, this function is empty and needs implementation.
#[test]
fun test_drop_semantics() {
    let test = test_scenario::begin(@cafe);
    let _dropable_weapon = create_insignificant_weapon(10);
    let weapon = create_weapon(20);
    assert!(weapon.power == 20);
    destroy(weapon);
    test.end();
}

// Additional Notes:
// 1. The `mint_hero` function could be extended to include additional properties for the `Hero` structure.
//    For example, attributes like `name`, `level`, or `skills` could be added.
// 2. The `create_insignificant_weapon` function could be enhanced to include more attributes for the weapon,
//    such as `type`, `durability`, or `rarity`.
// 3. The test functions are placeholders and need to be implemented to validate the functionality of the module.
//    For example, `test_mint` could verify that a `Hero` object is correctly created with a unique ID.
//    Similarly, `test_drop_semantics` could test the behavior of `InsignificantWeapon` when it is dropped.
// 4. Understanding the `TxContext` and its role in the Move ecosystem is crucial for extending this module.
//    It is used to manage transaction-related operations, such as creating new objects.
// 5. Consider adding documentation comments (`///`) for public functions and structures to improve code readability and usability.
