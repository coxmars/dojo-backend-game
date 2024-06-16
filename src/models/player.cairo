use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Player {
    #[key]
    player: ContractAddress,
    character: Character,
    score: u64
}

#[derive(Copy, Drop, Serde, Introspect)]
enum Character {
    Magician,
    Ninja,
    Samurai
}

impl CharacterIntoFelt252 of Into<Character, felt252> {
    fn into(self: Character) -> felt252 {
        match self {
            Character::Magician => 1,
            Character::Ninja => 2,
            Character::Samurai => 3
        }
    }
}