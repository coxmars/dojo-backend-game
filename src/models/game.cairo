use starknet::ContractAddress;

#[derive(Copy, Drop, Serde)]
#[dojo::model]
struct Game {
    #[key]
    player: ContractAddress,
    entityId: u32,
    status:
}

#[derive(Copy, Drop, Serde, Introspect, PartialEq, Print)]
struct GameStatus {
    Lobby: (),
    InProgress: (),
    Lost: (),
    Won: (),
}
