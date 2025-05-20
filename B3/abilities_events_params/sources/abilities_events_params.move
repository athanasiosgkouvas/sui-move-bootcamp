module abilities_events_params::abilities_events_params;

use std::string::String;
use sui::event;

//Error Codes
const EMedalOfHonorNotAvailable: u64 = 111;

// Structs

public struct Hero has key {
    id: UID, // required
    name: String,
    medals: vector<Medal>
}

public struct HeroMinted has copy, drop {
    hero: ID,
    owner: address
}

public struct HeroRegistry has key, store {
    id: UID,
    heroes: vector<ID>
}

public struct Medal has key, store {
    id: UID, 
    name: String
}

public struct MedalStorage has key, store {
    id: UID,
    medals: vector<Medal>
}

fun create_medal_of_honor(ctx: &mut TxContext): Medal {
    Medal{
        id: object::new(ctx),
        name: b"medal of honor".to_string()
    }
}

public fun award_medal_of_honor(hero: &mut Hero, medal_storage: &mut MedalStorage){
    assert!(medal_storage.medals.length() > 0, EMedalOfHonorNotAvailable);
    let medal = medal_storage.medals.pop_back();
    hero.medals.push_back(medal);
}

// Module Initializer
fun init(ctx: &mut TxContext) {
    let registry = HeroRegistry{
        id: object::new(ctx),
        heroes: vector[]
    };
    transfer::share_object(registry);

    let medal = create_medal_of_honor(ctx);

    let medal_storage = MedalStorage {
        id: object::new(ctx),
        medals: vector[medal]
    };
    transfer::share_object(medal_storage);
}


public fun mint_hero(registry: &mut HeroRegistry, name: String, ctx: &mut TxContext): Hero {
    let freshHero = Hero {
        id: object::new(ctx), // creates a new UID
        name: name,
        medals: vector[]
    };

    let minted = HeroMinted{
      hero: object::id(&freshHero),
      owner: ctx.sender()  
    };
    event::emit(minted);

    registry.heroes.push_back(object::id(&freshHero));

    freshHero
}

public entry fun mint_and_keep_hero(registry: &mut HeroRegistry, name: String, ctx: &mut TxContext) {
    let hero = mint_hero(registry, name, ctx);
    transfer::transfer(hero, ctx.sender());
}

/////// Tests ///////

#[test_only]
use sui::test_scenario as ts;
#[test_only]
use sui::test_scenario::{take_shared, return_shared};
#[test_only]
use sui::test_utils::{destroy, assert_eq};

//--------------------------------------------------------------
//  Test 1: Hero Creation
//--------------------------------------------------------------
//  Objective: Verify the correct creation of a Hero object.
//  Tasks:
//      1. Complete the test by calling the mint_hero function with a hero name.
//      2. Assert that the created Hero's name matches the provided name.
//      3. Properly clean up the created Hero object using destroy.
//--------------------------------------------------------------
#[test]
fun test_hero_creation() {
    let mut test = ts::begin(@USER);
    init(test.ctx());
    test.next_tx(@USER);

    let mut registry = HeroRegistry{
        id: object::new(test.ctx()),
        heroes: vector[]
    };

    let hero = mint_hero(&mut registry, b"Flash".to_string(), test.ctx());
    assert_eq(hero.name, b"Flash".to_string());

    destroy(hero);
    destroy(registry);
    test.end();
}

//--------------------------------------------------------------
//  Test 2: Event Emission
//--------------------------------------------------------------
//  Objective: Implement event emission during hero creation and verify its correctness.
//  Tasks:
//      1. Define a `HeroMinted` event struct with appropriate fields (e.g., hero ID, owner address).  Remember to add `copy, drop` abilities!
//      2. Emit the `HeroMinted` event within the `mint_hero` function after creating the Hero.
//      3. In this test, capture emitted events using `event::events_by_type<HeroMinted>()`.
//      4. Assert that the number of emitted `HeroMinted` events is 1.
//      5. Assert that the `owner` field of the emitted event matches the expected address (e.g., @USER).
//--------------------------------------------------------------
#[test]
fun test_event_thrown() {
    let mut test = ts::begin(@USER);
    init(test.ctx());
    test.next_tx(@USER);
    let mut registry = HeroRegistry{
        id: object::new(test.ctx()),
        heroes: vector[]
    };

    let hero = mint_hero(&mut registry,b"Flash".to_string(), test.ctx());
    let events = event::events_by_type<HeroMinted>();

    assert!(events.length() == 1);
    assert!(events[0].owner == @USER);
    destroy(hero);
    destroy(registry);
    test.end();
}

//--------------------------------------------------------------
//  Test 3: Medal Awarding
//--------------------------------------------------------------
//  Objective: Implement medal awarding functionality to heroes and verify its effects.
//  Tasks:
//      1. Define a `Medal` struct with appropriate fields (e.g., medal ID, medal name). Remember to add `key, store` abilities!
//      2. Add a `medals: vector<Medal>` field to the `Hero` struct to store the medals a hero has earned.
//      3. Create functions to award medals to heroes, e.g., `award_medal_of_honor(hero: &mut Hero)`.
//      4. In this test, mint a hero.
//      5. Award a specific medal (e.g., Medal of Honor) to the hero using your `award_medal_of_honor` function.
//      6. Assert that the hero's `medals` vector now contains the awarded medal.
//      7. Consider creating a shared `MedalStorage` object to manage the available medals.
//--------------------------------------------------------------

#[test]
fun test_medal_award() { 
    let mut test = ts::begin(@USER);
    init(test.ctx());
    test.next_tx(@USER);

    let mut medal_storage = take_shared<MedalStorage>(&test);
    let mut registry = take_shared<HeroRegistry>(&test);
    assert!(medal_storage.medals.length() == 1);
    let mut hero = mint_hero(&mut registry,b"Flash".to_string(), test.ctx());
    hero.award_medal_of_honor(&mut medal_storage);
    assert!(hero.medals.length() == 1);
    assert!(hero.medals[0].name == b"medal of honor".to_string());
    assert!(medal_storage.medals.length() == 0);
    return_shared(medal_storage);
    return_shared(registry);

    destroy(hero);
    test.end();
 }
