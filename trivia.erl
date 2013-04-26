-module(trivia).

-export([start/0]).

-record(game, {players = [], places = [], purses = [], in_penalty_box = [], pop_qestions = [], current_player = 0,
               pop_questions = [], science_questions = [], sports_question = [], rock_questions = [], is_getting_out_of_penalty_box = false }).

start() ->

    Game = for(#game{}, 50),

	Agame = add("Chet", Game),
	Agame2 = add("Pat", Agame),
	Agame3 = add("Sue", Agame2),

	do(Agame3).

for(Game, N) when N =< 0 ->
    Game;
for(Game, N) when N > 0 ->
    NewN = N -1,
    NewGame = Game#game{
        pop_questions = [io_lib:format( "Pop Question ~p", [N]) | Game#game.pop_questions],
        science_questions = [io_lib:format( "Science Question ~p", [N]) | Game#game.science_questions],
        sports_question = [io_lib:format( "Sports Question ~p", [N]) | Game#game.sports_question],
        rock_questions = [io_lib:format( "Rock Question ~p", [N]) | Game#game.rock_questions]
    },
    for(NewGame, NewN).

do(Agame) ->
	{A1,A2,A3} = now(),
    random:seed(A1, A2, A3),

	Agame1 = roll(random:uniform(5)+1, Agame),

	{NotAWinner, NGame} = case (random:uniform(9) =:= 7) of
		true -> wrong_answer(Agame1);
		false -> was_correctly_answered(Agame1)
	end,

	case NotAWinner of
		true -> do(NGame);
		false -> false
	end.

roll(Roll, Agame) ->
	io:format("~s is the current player~n", [proplists:get_value(Agame#game.current_player, Agame#game.players)]),
    io:format("They have rolled a ~p~n" , [Roll]),

    Game = case proplists:get_value(Agame#game.current_player, Agame#game.in_penalty_box) of
        false ->
            Agame3 = Agame#game{places = update_proplist(Agame#game.places, Agame#game.current_player, proplists:get_value(Agame#game.current_player, Agame#game.places)+Roll)},

            Agame4 = case (proplists:get_value(Agame3#game.current_player, Agame3#game.places) > 11) of
                true ->
                    Agame3#game{places = update_proplist(Agame3#game.places, Agame3#game.current_player, proplists:get_value(Agame3#game.current_player, Agame3#game.places)-12)};
                false -> Agame3
            end,

            io:format("~s's new location is ~p~n", [proplists:get_value(Agame4#game.current_player, Agame4#game.players), proplists:get_value(Agame4#game.current_player, Agame4#game.places)]),
            io:format("The category is ~p~n", [current_category(proplists:get_value(Agame4#game.current_player, Agame4#game.places))]),
            Agame5 = ask_question(Agame4),
            Agame5;
        _ ->
            case (Roll rem 2 =/= 0) of
                true ->
                    Agame2 = Agame#game{is_getting_out_of_penalty_box = true},
                    io:format("~p is getting out of the penalty box~n", [proplists:get_value(Agame2#game.current_player, Agame2#game.players)]),
                    Agame3 = Agame2#game{places = update_proplist(Agame2#game.places, Agame2#game.current_player, proplists:get_value(Agame2#game.current_player, Agame2#game.places)+Roll)},

                    Agame4 = case (proplists:get_value(Agame3#game.current_player, Agame3#game.places) > 11) of
                        true ->
                            Agame3#game{places = update_proplist(Agame3#game.places, Agame3#game.current_player, proplists:get_value(Agame3#game.current_player, Agame3#game.places)-12)};
                        false -> Agame3
                    end,

                    io:format("~s's new location is ~p~n", [proplists:get_value(Agame4#game.current_player, Agame4#game.players), proplists:get_value(Agame4#game.current_player, Agame4#game.places)]),
                    io:format("The category is ~p~n", [current_category(proplists:get_value(Agame4#game.current_player, Agame4#game.places))]),
                    Agame5 = ask_question(Agame4),
                    Agame5;
                false ->
                	io:format("~p is not getting out of the penalty box~n", [proplists:get_value(Agame#game.current_player, Agame#game.players)]),
                    Agame#game{is_getting_out_of_penalty_box = false}
            end
    end,

    Game.

ask_question(Game) ->
    case current_category(proplists:get_value(Game#game.current_player, Game#game.places)) of
        "Pop" ->
            [_|New] = Game#game.pop_questions,
            Game#game{pop_questions = New};
        "Science" ->
            [_|New] = Game#game.science_questions,
            Game#game{science_questions = New};
        "Sports" ->
            [_|New] = Game#game.sports_question,
            Game#game{sports_question = New};
        "Rock" ->
            [_|New] = Game#game.rock_questions,
            Game#game{rock_questions = New}
    end.

current_category(0) -> "Pop";
current_category(4) -> "Pop";
current_category(8) -> "Pop";
current_category(1) -> "Science";
current_category(5) -> "Science";
current_category(9) -> "Science";
current_category(2) -> "Sports";
current_category(6) -> "Sports";
current_category(10) -> "Sports";
current_category(_) -> "Rock".

update_proplist(Proplist, Key, NewValue) ->
    [{Key, NewValue} | proplists:delete(Key, Proplist)].

wrong_answer(Game) ->
    io:format("Question was incorrectly answered~n", []),
    io:format("~s was sent to the penalty box~n", [proplists:get_value(Game#game.current_player, Game#game.players)]),


    Game1 = Game#game{
        in_penalty_box = update_proplist(Game#game.in_penalty_box, Game#game.current_player, true),
        current_player = Game#game.current_player + 1
    },

    Game2 = case (Game1#game.current_player =:= how_many_players(Game1)) of
        true ->
            Game1#game{ current_player = 0};
        false -> Game1
    end,

    {true, Game2}.

was_correctly_answered(Game) ->

    {Winner, Game1} = case proplists:get_value(Game#game.current_player, Game#game.in_penalty_box) of
        true ->
            {W, G } = case ( Game#game.is_getting_out_of_penalty_box =:= true ) of
                true ->

                    io:format("Answer was corrent!!!!~n", []),

                    G1 = Game#game{
                        purses = update_proplist(
                            Game#game.purses, Game#game.current_player, proplists:get_value(Game#game.current_player, Game#game.purses)+1
                        ),
                        current_player = Game#game.current_player + 1
                    },

                    io:format("~s now has ~p Gold Coins~n", [
                        proplists:get_value(Game#game.current_player, Game#game.players),
                        proplists:get_value(G1#game.current_player, G1#game.purses)
                    ]),

                    W2 = did_player_win(G1),

                    G2 = case (G1#game.current_player =:= how_many_players(G1)) of
                        true ->
                            G1#game{ current_player = 0};
                        false -> G1
                    end,
                    {W2, G2};


                false ->
                    G1 = Game#game{
                        current_player = Game#game.current_player + 1
                    },

                    G2 = case (G1#game.current_player =:= how_many_players(G1)) of
                        true ->
                            G1#game{ current_player = 0};
                        false -> G1
                    end,
                    {true, G2}

            end,
            {W, G};
        false ->
            io:format("Answer was corrent!!!!~n", []),

            G1 = Game#game{
                purses = update_proplist(
                    Game#game.purses, Game#game.current_player, proplists:get_value(Game#game.current_player, Game#game.purses)+1
                ),
                current_player = Game#game.current_player + 1
            },

            io:format("~s now has ~p Gold Coins~n", [
                proplists:get_value(Game#game.current_player, Game#game.players),
                proplists:get_value(G1#game.current_player, G1#game.purses)
            ]),

            W = did_player_win(G1),

            G2 = case (G1#game.current_player =:= how_many_players(G1)) of
                true ->
                    G1#game{ current_player = 0};
                false -> G1
            end,
            {W, G2}
    end,


    {Winner, Game1}.

add(PlayerName, Game2) ->
	Game3 = Game2#game{places = [{how_many_players(Game2),0}|Game2#game.places]},
	Game4 = Game3#game{purses = [{how_many_players(Game3),0}|Game3#game.purses]},
	Game5 = Game4#game{in_penalty_box = [{how_many_players(Game4),false}|Game4#game.in_penalty_box]},
        Game6 = Game5#game{players = [{how_many_players(Game5),PlayerName}|Game5#game.players]},

	io:format("~s was added~n", [PlayerName]),
	io:format("They are player number ~p~n", [Game5#game.places]),

    Game6.

how_many_players(Game) ->
	length(Game#game.players).

did_player_win(Game) ->
    case (proplists:get_value(Game#game.current_player, Game#game.purses) =:= 6) of
        true -> false;
        false -> true
    end.
