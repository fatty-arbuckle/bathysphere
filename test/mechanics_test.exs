defmodule MechanicsTest do
  use ExUnit.Case

  @base_state %Bathysphere.Game.State{
    dice_pool_size: 1,
    dice_pool: [],
    map: [],
    state: :ok,
    position: 0,
    remaining: 0,
    score: 0,
    oxygen: [{:oxygen, false},{:oxygen, false}],
    stress: [{:stress, false},{:stress, false}],
    damage: [{:damage, false},{:damage, false}],
    fish_points: [+2, +2, +3],
    octopus_points: [+3, +5]
  }

  test "moving down onto empty space" do
    game_state = %{ @base_state |
      dice_pool: [1],
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:stress, -1, false}], marked?: false } },
      ]
    }
    expected_state = %{ game_state |
      dice_pool: [],
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:stress, -1, false}], marked?: true } },
      ],
      position: 1
    }
    assert {:ok, expected_state} == Bathysphere.Game.Mechanics.down(game_state, 1)
  end

  test "moving down onto a marked space" do
    game_state = %{ @base_state |
      dice_pool: [1],
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:stress, -1, false}], marked?: true } },
      ]
    }
    expected_state = %{ game_state |
    dice_pool: [],
    map: [
        { :start, %{} },
        { :space, %{ actions: [{:stress, -1, false}], marked?: true } },
      ],
      position: 1,
      stress: [{:stress, true},{:stress, false}]
    }
    assert {:ok, expected_state} == Bathysphere.Game.Mechanics.down(game_state, 1)
  end

  test "moving down and discovering an octopus" do
    game_state = %{ @base_state |
      dice_pool: [1],
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:discovery, :octopus, nil}], marked?: false } },
      ]
    }
    expected_state = %{ game_state |
      dice_pool: [],
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:discovery, :octopus, nil}], marked?: true } },
      ],
      position: 1,
      score: 3
    }
    assert {:ok, expected_state} == Bathysphere.Game.Mechanics.down(game_state, 1)
  end

  test "moving down and discovering an fish" do
    game_state = %{ @base_state |
      dice_pool: [1],
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:discovery, :fish, nil}], marked?: false } },
      ]
    }
    expected_state = %{ game_state |
      dice_pool: [],
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:discovery, :fish, nil}], marked?: true } },
      ],
      position: 1,
      score: 2
    }
    assert {:ok, expected_state} == Bathysphere.Game.Mechanics.down(game_state, 1)
  end

  test "moving down past actions" do
    game_state = %{ @base_state |
      dice_pool: [6],
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:oxygen, -1, false}], marked?: false } },
        { :space, %{ actions: [{:stress, -1, false}], marked?: false } },
        { :space, %{ actions: [{:damage, -2, false}], marked?: false } },
        { :space, %{ actions: [{:stress, -1, false}], marked?: false } },
        { :space, %{ actions: [{:discovery, :fish, false}], marked?: false } },
        { :space, %{ actions: [], marked?: false } },
      ]
    }
    expected_state = %{ game_state |
      state: :dead,
      dice_pool: [],
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:oxygen, -1, true}], marked?: false } },
        { :space, %{ actions: [{:stress, -1, true}], marked?: false } },
        { :space, %{ actions: [{:damage, -2, true}], marked?: false } },
        { :space, %{ actions: [{:stress, -1, true}], marked?: false } },
        { :space, %{ actions: [{:discovery, :fish, true}], marked?: false } },
        { :space, %{ actions: [], marked?: true } },
      ],
      position: 6,
      oxygen: [{:oxygen, true},{:oxygen, false}],
      stress: [{:stress, true},{:stress, true}],
      damage: [{:damage, true},{:damage, true}]
    }
    assert {:dead, expected_state} == Bathysphere.Game.Mechanics.down(game_state, 6)
  end

  test "moving down past marked spaces" do
    game_state = %{ @base_state |
      dice_pool: [5],
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:oxygen, -1, false}], marked?: true } },
        { :space, %{ actions: [{:stress, -1, true}], marked?: true } },
        { :space, %{ actions: [{:damage, -2, true}], marked?: true } },
        { :space, %{ actions: [{:stress, -1, false}], marked?: true } },
        { :space, %{ actions: [], marked?: false } },
      ]
    }
    expected_state = %{ game_state |
      dice_pool: [],
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:oxygen, -1, false}], marked?: true } },
        { :space, %{ actions: [{:stress, -1, true}], marked?: true } },
        { :space, %{ actions: [{:damage, -2, true}], marked?: true } },
        { :space, %{ actions: [{:stress, -1, false}], marked?: true } },
        { :space, %{ actions: [], marked?: true } },
      ],
      position: 5
    }
    assert {:ok, expected_state} == Bathysphere.Game.Mechanics.down(game_state, 5)
  end

  test "moving down past depth_zone" do
    game_state = %{ @base_state |
      dice_pool: [3],
      map: [
        { :start, %{} },
        { :space, %{ actions: [], marked?: false } },
        { :depth_zone, %{} },
        { :space, %{ actions: [], marked?: false } },
        { :space, %{ actions: [], marked?: false } },
        { :space, %{ actions: [], marked?: false } },
      ]
    }
    expected_state = %{ game_state |
      state: :dead,
      dice_pool: [],
      map: [
        { :start, %{} },
        { :space, %{ actions: [], marked?: false } },
        { :depth_zone, %{} },
        { :space, %{ actions: [], marked?: false } },
        { :space, %{ actions: [], marked?: true } },
        { :space, %{ actions: [], marked?: false } },
      ],
      position: 4,
      stress: [{:stress, true},{:stress, true}]
    }
    assert {:dead, expected_state} == Bathysphere.Game.Mechanics.down(game_state, 3)
  end

  test "moving down past the bottom" do
    game_state = %{ @base_state |
      dice_pool: [3],
      map: [
        { :start, %{} },
        { :space, %{ actions: [], marked?: false } },
        { :space, %{ actions: [], marked?: false } },
      ]
    }
    expected_state = %{ game_state |
      dice_pool: [],
      map: [
        { :start, %{} },
        { :space, %{ actions: [], marked?: false } },
        { :space, %{ actions: [], marked?: true } },
      ],
      position: 2,
      stress: [{:stress, true},{:stress, false}]
    }
    assert {:ok, expected_state} == Bathysphere.Game.Mechanics.down(game_state, 3)
  end

  test "moving up" do
    game_state = %{ @base_state |
      dice_pool: [5],
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:oxygen, -1, false}], marked?: false } },
        { :space, %{ actions: [{:stress, -1, true}], marked?: false } },
        { :space, %{ actions: [{:damage, -2, true}], marked?: false } },
        { :space, %{ actions: [{:stress, -1, false}], marked?: false } },
        { :space, %{ actions: [], marked?: true } }
      ],
      position: 5
    }
    expected_state = %{ game_state |
      state: :complete,
      dice_pool: [],
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:oxygen, -1, true}], marked?: false } },
        { :space, %{ actions: [{:stress, -1, true}], marked?: false } },
        { :space, %{ actions: [{:damage, -2, true}], marked?: false } },
        { :space, %{ actions: [{:stress, -1, true}], marked?: false } },
        { :space, %{ actions: [], marked?: true } }
      ],
      position: 0,
      stress: [{:stress, true},{:stress, false}],
      oxygen: [{:oxygen, true},{:oxygen, false}],
      damage: [{:damage, false},{:damage, false}]
    }
    assert {:complete, expected_state} == Bathysphere.Game.Mechanics.up(game_state, 5)
  end

  test "completing the game" do
    game_state = %{ @base_state |
      dice_pool: [ 3 ],
      map: [
        { :start, %{} },
        { :space, %{ actions: [], marked?: false } },
        { :space, %{ actions: [], marked?: false } },
        { :space, %{ actions: [], marked?: true } }
      ],
      position: 3
    }
    expected_state = %{ game_state |
      state: :complete,
      dice_pool: [],
      map: [
        { :start, %{} },
        { :space, %{ actions: [], marked?: false } },
        { :space, %{ actions: [], marked?: false } },
        { :space, %{ actions: [], marked?: true } }
      ],
      position: 0
    }
    assert {:complete, expected_state} == Bathysphere.Game.Mechanics.up(game_state, 3)
    assert {:complete, expected_state} == Bathysphere.Game.Mechanics.up(expected_state, 1)
    assert {:complete, expected_state} == Bathysphere.Game.Mechanics.down(expected_state, 1)
  end

  test "running out of stress" do
    game_state = %{ @base_state |
      dice_pool: [3],
      map: [
        { :start, %{} },
        { :depth_zone, %{} },
        { :space, %{ actions: [{:stress, -1, false}], marked?: false } },
        { :space, %{ actions: [], marked?: false } },
        { :depth_zone, %{} },
        { :space, %{ actions: [], marked?: false } },
      ]
    }
    expected_state = %{ game_state |
      state: :dead,
      dice_pool: [],
      map: [
        { :start, %{} },
        { :depth_zone, %{} },
        { :space, %{ actions: [{:stress, -1, true}], marked?: false } },
        { :space, %{ actions: [], marked?: false } },
        { :depth_zone, %{} },
        { :space, %{ actions: [], marked?: true } },
      ],
      position: 5,
      stress: [{:stress, true},{:stress, true}]
    }
    assert {:dead, expected_state} == Bathysphere.Game.Mechanics.down(game_state, 3)
  end

  test "running out of damage" do
    game_state = %{ @base_state |
      dice_pool: [4],
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:damage, -1, false}], marked?: false } },
        { :space, %{ actions: [], marked?: false } },
        { :space, %{ actions: [{:damage, -1, false}], marked?: false } },
        { :space, %{ actions: [], marked?: false } },
      ]
    }
    expected_state = %{ game_state |
      state: :dead,
      dice_pool: [],
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:damage, -1, true}], marked?: false } },
        { :space, %{ actions: [], marked?: false } },
        { :space, %{ actions: [{:damage, -1, true}], marked?: false } },
        { :space, %{ actions: [], marked?: true } },
      ],
      position: 4,
      damage: [{:damage, true},{:damage, true}]
    }
    assert {:dead, expected_state} == Bathysphere.Game.Mechanics.down(game_state, 4)
  end

  test "running out of oxygen" do
    game_state = %{ @base_state |
      dice_pool: [3],
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:oxygen, -2, false}], marked?: false } },
        { :space, %{ actions: [], marked?: false } },
        { :space, %{ actions: [], marked?: false } },
      ]
    }
    expected_state = %{ game_state |
      state: :dead,
      dice_pool: [],
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:oxygen, -2, true}], marked?: false } },
        { :space, %{ actions: [], marked?: false } },
        { :space, %{ actions: [], marked?: true } },
      ],
      position: 3,
      oxygen: [{:oxygen, true},{:oxygen, true}]
    }
    assert {:dead, expected_state} == Bathysphere.Game.Mechanics.down(game_state, 3)
  end

  test "getting points for discoveries" do
    game_state = %{ @base_state |
      dice_pool: [ 1, 1, 1, 1, 1, 1 ],
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:discovery, :fish, nil}], marked?: false } },
        { :space, %{ actions: [{:discovery, :octopus, nil}], marked?: false } },
        { :space, %{ actions: [{:discovery, :fish, nil}], marked?: false } },
        { :space, %{ actions: [{:discovery, :octopus, nil}], marked?: false } },
        { :space, %{ actions: [{:ocean_floor, +2, nil}], marked?: false } },
        { :space, %{ actions: [{:ocean_floor, +4, nil}], marked?: false } }
      ]
    }
    expected_state = %{ game_state |
      dice_pool: [],
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:discovery, :fish, nil}], marked?: true } },
        { :space, %{ actions: [{:discovery, :octopus, nil}], marked?: true } },
        { :space, %{ actions: [{:discovery, :fish, nil}], marked?: true } },
        { :space, %{ actions: [{:discovery, :octopus, nil}], marked?: true } },
        { :space, %{ actions: [{:ocean_floor, +2, nil}], marked?: true } },
        { :space, %{ actions: [{:ocean_floor, +4, nil}], marked?: true } }
      ],
      position: 6,
      score: 18
    }
    assert expected_state == Enum.reduce(0..5, game_state, fn _, acc ->
      {:ok, updated} = Bathysphere.Game.Mechanics.down(acc, 1)
      updated
    end)
  end

  test "moving N removes an N die from the dice pool" do
    game_state = %{ @base_state |
      dice_pool_size: 3,
      dice_pool: [ 1, 2, 6, 1, 1 ],
      map: [
        { :start, %{} },
        { :space, %{ actions: [], marked?: false } },
        { :space, %{ actions: [], marked?: false } },
        { :space, %{ actions: [], marked?: false } },
        { :space, %{ actions: [], marked?: false } },
        { :space, %{ actions: [], marked?: false } },
      ]
    }
    expected_state = %{ game_state |
      dice_pool_size: 3,
      dice_pool: [ 6, 1 ],
      map: [
        { :start, %{} },
        { :space, %{ actions: [], marked?: false } },
        { :space, %{ actions: [], marked?: true } },
        { :space, %{ actions: [], marked?: true } },
        { :space, %{ actions: [], marked?: true } },
        { :space, %{ actions: [], marked?: false } },
      ],
      position: 4
    }
    final_state = Bathysphere.Game.Mechanics.down(game_state, 2)
    |> elem(1)
    |> Bathysphere.Game.Mechanics.down(1)
    |> elem(1)
    |> Bathysphere.Game.Mechanics.down(1)

    assert {:ok, expected_state} == final_state

  end

  test "cannot move N without N die in the dice pool" do
    game_state = %{ @base_state |
      dice_pool_size: 3,
      dice_pool: [1, 3, 6]
    }
    expected_state = %{ game_state |
      dice_pool_size: 3,
      dice_pool: [1, 3, 6]
    }
    assert { :invalid_move, expected_state } == Bathysphere.Game.Mechanics.down(game_state, 2)
    assert { :invalid_move, expected_state } == Bathysphere.Game.Mechanics.up(game_state, 4)
  end

  test "initial population of the dice pool" do
    game_state = %{ @base_state |
      dice_pool_size: 3,
      dice_pool: []
    }
    {:ok, updated_state} = Bathysphere.Game.Mechanics.roll(game_state, :init)
    assert game_state.dice_pool_size == Enum.count(updated_state.dice_pool)
    Enum.each(updated_state.dice_pool, fn die ->
      assert die <= 6 and die >= 1
    end)
  end

  test "re-population of the dice pool" do
    game_state = %{ @base_state |
      dice_pool_size: 3,
      dice_pool: [ 7, 8, 9 ],
      oxygen: [{:oxygen, false},{:oxygen, false}]
    }
    { :ok, updated_state } = Bathysphere.Game.Mechanics.roll(game_state)
    assert game_state.dice_pool_size == Enum.count(updated_state.dice_pool)
    assert game_state.dice_pool != updated_state.dice_pool
    assert [{:oxygen, true},{:oxygen, false}] = updated_state.oxygen
  end

  test "rerolling the dice can kill you" do
    game_state = %{ @base_state |
      dice_pool_size: 3,
      dice_pool: [ 1, 5, 2 ],
      oxygen: [{:oxygen, true},{:oxygen, false}]
    }
    expected_state = %{ game_state |
      state: :dead,
      dice_pool_size: 3,
      dice_pool: [ 1, 5, 2 ],
      oxygen: [{:oxygen, true},{:oxygen, true}]
    }
    { final_state, updated_state } = Bathysphere.Game.Mechanics.roll(game_state)
    assert {:dead, expected_state} == { final_state, %{ updated_state | dice_pool: [ 1, 5, 2 ] } }
  end

  test "select action when passing a space with multiple actions" do
  end

  test "moving back over a space with actions a second time" do
  end

  test "triggering damage from stress" do
  end

  test "losing dice from oxygen" do
  end

end
