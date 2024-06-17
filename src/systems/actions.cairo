use dojo_starter::models::{player::Character, skill::SkillType};

// define the interface
#[dojo::interface]
trait IActions {
    fn spawn(character: Character);
    fn action(skill: SkillType);
}

// dojo decorator
#[dojo::contract]
mod actions {
    use super::{IActions};
    use starknet::{ContractAddress, get_caller_address, contract_address_const};
    use dojo_starter::models::{player::{Character, Player}, skill::{SkillType, Skill}, 
    counter::Counter, game::{Game, GameStatus, GameStatusImplTrait}, health:: Health};

    const GOBLIN_ID: felt252 = 0x676f626c696e;
    const COUNTER_ID: u32 = 999999999;

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        CharacterAction: CharacterAction,
    }

    #[derive(Drop, Serde, starknet::Event)]
    struct CharacterAction {
        player: ContractAddress,
        action: SkillType,
        skillValue: u16
    }

    #[abi(embed_v0)]
    impl ActionsImpl of IActions<ContractState> {
        fn spawn(ref world: IWorldDispatcher, character: Character) {
           let player = get_caller_address();
           let mut attack: u16 = 0;
           let mut strongAttack: u16 = 0;
           let mut healing: u16 = 0;

           let platerStatus = get!(world, player, (Player));
           let currentCounter = get!(world, COUNTER_ID, (Counter));
           let gameCounter = currentCounter.counter + 1;

           match character {
            Character::Magician => {
                attack = 15;
                strongAttack = 20;
                healing = 25;
            },
            Character::Ninja => {
                attack = 10;
                strongAttack = 30;
                healing = 20;
            },
            Character::Samurai => {
                attack = 20;
                strongAttack = 40;
                healing = 25;
            }
           }

           set!(world, (
            Player {player, character, score: playerStatus.score},
            Game {player, entityId: gameCounter, status: GameStatus::InProgress},
            Health {entityId: player, gameId: gameCounter, health: 100},
            Skill {entityId: player, gameId: gameCounter, attack, strongAttack, healing}
           ))

           // spawn goblin
           set!(world, (
            Health {entityId: contract_address_const::<GOBLIN_ID>(), gameId: gameCounter, health: 100},
            Skill {entityId: contract_address_const::<GOBLIN_ID>(), gameId: gameCounter, attack, strongAttack, healing}
           ))
        }

        // Implementation of the action function for the ContractState struct.
        fn action(ref world: IWorldDispatcher, skill: SkillType) {
            let player = get_caller_address();
            let (mut playerCharacter, mut gameStatus) = get!(world, player, (Player, Game));

            // plaer health and skill
            let (mut playerHealth, playerSkill) = get!(world, (player, GameStatus.entityId), (Health, Skill));

            // goblin health and skill
            let (mut goblinHealth, goblinSkill) = get!(world, (contract_address_const::<GOBLIN_ID>(), GameStatus.entityId), (Health, Skill));

            gameStatus.assert_in_progress();
            let mut skillValue: u16 = 0;
            match skill {
                SkillType::Attack => {
                    skillValue = playerSkill.attack;
                    if goblinHealth.health > playerSkill.attack {
                        goblinHealth.health -= playerSkill.attack;
                    }
                    else {
                        goblinHealth.health = 0;
                        gameStatus.status = GameStatus::Won;
                        playerCharacter.score += 10;
                        set!(world, (playerCharacter, gameStatus));
                    }
                    set!(world, (goblinHealth));
                },
                SkillType::StrongAttack => {
                    skillValue = playerSkill.strongAttack;
                    if goblinHealth.health > playerSkill.strongAttack {
                        goblinHealth.health -= playerSkill.strongAttack;
                    }
                    else {
                        goblinHealth.health = 0;
                        gameStatus.status = GameStatus::Won;
                        playerCharacter.score += 10;
                        set!(world, (playerCharacter, gameStatus));
                    }
                    set!(world, (goblinHealth));
                },
                SkillType::Healing => {
                    skillValue = playerSkill.healing;
                    playerHealth.health += playerSkill.healing;
                    set!(world, (playerHealth));
                }
            }

            // emit user's action event
            emit!(world, (Event::CharacterAction(CharacterAction {player, action: skill, skillValue})));


            // goblin attack
            if goblinHealth.health > 0 {
                if playerHealth.health > goblinSkill.attack {
                    playerHealth.health -= goblinSkill.attack
                } 
                else {
                    playerHealth.health = 0;
                    gameStatus.status = GameStatus::Lost;
                    set!(world, (gameStatus));
                }

                set!(world, (playerHealth));
                
                // event goblin action event
                emit!(world, (Event::CharacterAction(CharacterAction {player: contract_address_const::<GOBLIN_ID>(), action: SkillType::Attack, skillValue: goblinSkill.attack})));

            }
        }
    }
}