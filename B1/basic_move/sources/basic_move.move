module basic_move::basic_move;

use sui::test_scenario::{begin};
use std::string::{utf8, String};

const EAlreadyCarriesWeapon: u64 = 1;

public struct Hero has key, store {
    id: UID,
    name: String,
    stamina: u64,
    weapon: Option<Weapon>
}

public struct Weapon has key, store {
    id: UID, 
    name: String, 
    power: u64
}


public fun mint_hero(name_param: String, stamina_param: u64, ctx: &mut TxContext): Hero {
    let aHero = Hero {
        id: object::new(ctx),
        name: name_param,
        stamina: stamina_param, 
        weapon: option::none()
    };
    aHero
}

public fun create_weapon(
    name_param: String, 
    power_param: u64, 
    ctx: &mut TxContext
): Weapon {
    Weapon {
        id: object::new(ctx),
        name: name_param, 
        power: power_param
    }
}

public fun equip_hero(hero: &mut Hero, weapon: Weapon) {
    assert!(hero.weapon.is_none(), EAlreadyCarriesWeapon);
    hero.weapon.fill(weapon);
}

#[test]
fun test_mint() {
    let mut  test = begin(@0xCAFE);
    let hero = mint_hero(utf8(b"test name"), 55, test.ctx()); //use utf8 to write whatever we want
    assert!(hero.name == b"test name".to_string(), 666);
    
    destroy_for_testing(hero);
    test.end();
}


#[test]
fun test_equip() {
    let mut test = begin(@0xCAFE);
    let mut hero = mint_hero(b"Batman".to_string(),66, test.ctx());
    let weapon = create_weapon(b"Gun".to_string(), 85, test.ctx());
    assert!(hero.name == b"Batman".to_string(), 666);
    assert!(hero.weapon.is_none(), 667);
    hero.equip_hero(weapon);
    assert!(hero.weapon.is_some(), 668);
    assert!(hero.weapon.borrow().name == b"Gun".to_string(), 669);

    destroy_for_testing(hero);
    test.end();
}

#[test]
#[expected_failure(abort_code=EAlreadyCarriesWeapon)]
fun test_equip_with_error() {
    let mut test = begin(@0xCAFE);
    let mut hero = mint_hero(b"Batman".to_string(),66, test.ctx());
    let weapon = create_weapon(b"Gun".to_string(), 85, test.ctx());
    assert!(hero.name == b"Batman".to_string(), 666);
    assert!(hero.weapon.is_none(), 667);
    hero.equip_hero(weapon);
    let weapon2 = create_weapon(b"Batmobile".to_string(), 50, test.ctx());
    hero.equip_hero(weapon2);

    destroy_for_testing(hero);
    test.end();
}

#[test_only]
fun destroy_for_testing(hero: Hero) {
    let Hero {
        id: id, 
        name: _, 
        stamina: _, 
        weapon: _w
    } = hero;
    object::delete(id);
    if(_w.is_some()) {
        let Weapon {
            id: wid, 
            name: _, 
            power: _
        } = _w.destroy_some();
        object::delete(wid)
    } else {
        _w.destroy_none()
    }
}