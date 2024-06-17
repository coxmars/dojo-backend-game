use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Game {
    #[key]
    player: ContractAddress,
    entityId: u32,
    status: GameStatus
}

#[derive(Copy, Drop, Serde, Introspect, PartialEq, Print)]
enum GameStatus {
    Lobby: (),
    InProgress: (),
    Lost: (),
    Won: (),
}

impl GameStatusFelt252 of Into<GameStatus, felt252> {
    fn into(self: GameStatus) -> felt252 {
        match self {
            GameStatus::Lobby => 1,
            GameStatus::InProgress => 2,
            GameStatus::Lost => 3,
            GameStatus::Won => 4,
        }
    }
}

#[generate_trait]
impl GameStatusImpl of GameStatusImplTrait {
    fn assert_in_progress(self: Game){
        assert(self.status == GameStatus::InProgress, 'Game not started');
    }

    fn assert_lobby(self: Game){
        assert(self.status == GameStatus::Lobby, 'Game not in lobby');
    }
}