defmodule Teiserver.Battle.BalanceLibTest do
  use Central.DataCase, async: false
  alias Teiserver.Battle.BalanceLib
  alias Teiserver.Game.MatchRatingLib
  alias Teiserver.Account
  alias Teiserver.TeiserverTestLib
  alias Decimal, as: D

  setup do
    rating_type_id = MatchRatingLib.rating_type_name_lookup()["Small Team"]

    user1 = TeiserverTestLib.new_user()
    user2 = TeiserverTestLib.new_user()
    user3 = TeiserverTestLib.new_user()
    user4 = TeiserverTestLib.new_user()
    user5 = TeiserverTestLib.new_user()
    user6 = TeiserverTestLib.new_user()

    Account.create_rating(%{
      user_id: user1.id,
      rating_type_id: rating_type_id,

      rating_value: 20,
      skill: 25,
      uncertainty: 5,
    })

    Account.create_rating(%{
      user_id: user2.id,
      rating_type_id: rating_type_id,

      rating_value: 23,
      skill: 26,
      uncertainty: 3,
    })

    Account.create_rating(%{
      user_id: user3.id,
      rating_type_id: rating_type_id,

      rating_value: 25,
      skill: 30,
      uncertainty: 5,
    })

    Account.create_rating(%{
      user_id: user4.id,
      rating_type_id: rating_type_id,

      rating_value: 28,
      skill: 28,
      uncertainty: 0,
    })

    Account.create_rating(%{
      user_id: user5.id,
      rating_type_id: rating_type_id,

      rating_value: 40,
      skill: 50,
      uncertainty: 10,
    })

    Account.create_rating(%{
      user_id: user6.id,
      rating_type_id: rating_type_id,

      rating_value: 5,
      skill: 10,
      uncertainty: 5,
    })

    {:ok,
      user1: user1.id,
      user2: user2.id,
      user3: user3.id,
      user4: user4.id,
      user5: user5.id,
      user6: user6.id
    }
  end

  test "round robin basic 4", %{user1: user1, user2: user2, user3: user3, user4: user4} do
    result = BalanceLib.balance_players([user1, user2, user3, user4], 2, "Small Team", :round_robin)

    assert Enum.count(result.team_players[1]) == 2
    assert Enum.count(result.team_players[2]) == 2

    assert result.stats[1].total_rating == 56.0
    assert result.stats[2].total_rating == 53

    assert result.deviation == 6
  end

  test "round robin complex 6", %{user1: user1, user2: user2, user3: user3, user4: user4, user5: user5, user6: user6} do
    result = BalanceLib.balance_players([user1, user2, user3, user4, user5, user6], 2, "Small Team", :round_robin)

    assert Enum.count(result.team_players[1]) == 3
    assert Enum.count(result.team_players[2]) == 3

    assert result.stats[1].total_rating == 103
    assert result.stats[2].total_rating == 66

    assert result.deviation == 56
  end

  test "loser picks basic 4", %{user1: user1, user2: user2, user3: user3, user4: user4} do
    result = BalanceLib.balance_players([user1, user2, user3, user4], 2, "Small Team", :loser_picks)

    assert Enum.count(result.team_players[1]) == 2
    assert Enum.count(result.team_players[2]) == 2

    assert result.stats[1].total_rating == 55
    assert result.stats[2].total_rating == 54

    assert result.deviation == 2
  end

  test "loser picks complex 6", %{user1: user1, user2: user2, user3: user3, user4: user4, user5: user5, user6: user6} do
    result = BalanceLib.balance_players([user1, user2, user3, user4, user5, user6], 2, "Small Team", :loser_picks)

    assert Enum.count(result.team_players[1]) == 3
    assert Enum.count(result.team_players[2]) == 3

    assert result.stats[1].total_rating == 86
    assert result.stats[2].total_rating == 83

    assert result.deviation == 4
  end

  test "loser picks uneven 5", %{user1: user1, user2: user2, user3: user3, user4: user4, user5: user5} do
    result = BalanceLib.balance_players([user1, user2, user3, user4, user5], 2, "Small Team", :loser_picks)

    assert Enum.count(result.team_players[1]) == 2
    assert Enum.count(result.team_players[2]) == 3

    assert result.stats[1].total_rating == 76
    assert result.stats[2].total_rating == 83

    assert result.deviation == 9
  end
end
