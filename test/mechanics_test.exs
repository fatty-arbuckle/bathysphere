defmodule MechanicsTest do
  use ExUnit.Case

  @base_state %Bathysphere.Game.State{
    map: [],
    state: :ok,
    position: 0,
    remaining: 0,
    score: 0,
    fish_discovered: 0,
    octopus_discovered: 0,
    oxygen: [{:oxygen, false},{:oxygen, false}],
    stress: [{:stress, false},{:stress, false}],
    damage: [{:damage, false},{:damage, false}]
  }

  test "moving down onto empty space" do
    game_state = %{ @base_state |
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:stress, -1, false}], marked?: false } },
      ]
    }
    expected_state = %{ game_state |
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
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:stress, -1, false}], marked?: true } },
      ]
    }
    expected_state = %{ game_state |
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
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:discovery, :octopus, nil}], marked?: false } },
      ]
    }
    expected_state = %{ game_state |
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:discovery, :octopus, nil}], marked?: true } },
      ],
      position: 1,
      octopus_discovered: 1,
    }
    assert {:ok, expected_state} == Bathysphere.Game.Mechanics.down(game_state, 1)
  end

  test "moving down and discovering an fish" do
    game_state = %{ @base_state |
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:discovery, :fish, nil}], marked?: false } },
      ]
    }
    expected_state = %{ game_state |
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:discovery, :fish, nil}], marked?: true } },
      ],
      position: 1,
      fish_discovered: 1,
    }
    assert {:ok, expected_state} == Bathysphere.Game.Mechanics.down(game_state, 1)
  end

  test "moving down past actions" do
    game_state = %{ @base_state |
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
      map: [
        { :start, %{} },
        { :space, %{ actions: [], marked?: false } },
        { :space, %{ actions: [], marked?: false } },
      ]
    }
    expected_state = %{ game_state |
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
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:oxygen, -2, false}], marked?: false } },
        { :space, %{ actions: [], marked?: false } },
        { :space, %{ actions: [], marked?: false } },
      ]
    }
    expected_state = %{ game_state |
    state: :dead,
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
  end

  test "moving back over a space with actions a second time" do
  end

  test "triggering damage from stress" do
  end

  test "losing dice from oxygen" do
  end

end
