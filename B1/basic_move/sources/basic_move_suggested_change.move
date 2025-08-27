module basic_move::basic_move_suggested_change;
public struct Hero has key, store {
    id: object::UID,
}

public struct Pebble has drop, store {
    size: u8,
}

public fun mint_hero(ctx: &mut TxContext): Hero {
    let hero = Hero { id: object::new(ctx) };
    hero
}

public fun make_pebble(size: u8): Pebble {
    Pebble { size }
}

#[test]
fun test_mint() {}

#[test]
fun test_drop_semantics() {}
