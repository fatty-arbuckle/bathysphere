defmodule MechanicsTest do
  use ExUnit.Case

  @base_state %Bathysphere.Game.State{
    map: [],
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
    assert expected_state == Bathysphere.Game.Mechanics.down(game_state, 1)
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
    assert expected_state == Bathysphere.Game.Mechanics.down(game_state, 1)
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
    assert expected_state == Bathysphere.Game.Mechanics.down(game_state, 1)
  end

  test "moving down past actions" do
    game_state = %{ @base_state |
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:oxygen, -1, false}], marked?: false } },
        { :space, %{ actions: [{:stress, -1, false}], marked?: false } },
        { :space, %{ actions: [{:damage, -2, false}], marked?: false } },
        { :space, %{ actions: [{:stress, -1, false}], marked?: false } },
        { :space, %{ actions: [], marked?: false } },
      ]
    }
    expected_state = %{ game_state |
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:oxygen, -1, true}], marked?: false } },
        { :space, %{ actions: [{:stress, -1, true}], marked?: false } },
        { :space, %{ actions: [{:damage, -2, true}], marked?: false } },
        { :space, %{ actions: [{:stress, -1, true}], marked?: false } },
        { :space, %{ actions: [], marked?: true } },
      ],
      position: 5,
      oxygen: [{:oxygen, true},{:oxygen, false}],
      stress: [{:stress, true},{:stress, true}],
      damage: [{:damage, true},{:damage, true}]
    }
    assert expected_state == Bathysphere.Game.Mechanics.down(game_state, 5)
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
      position: 5,
      oxygen: [{:oxygen, false},{:oxygen, false}],
      stress: [{:stress, false},{:stress, false}],
      damage: [{:damage, false},{:damage, false}]
    }
    assert expected_state == Bathysphere.Game.Mechanics.down(game_state, 5)
  end

  test "moving down past depth_zone" do

  end

  test "moving down past the bottom" do

  end

  test "moving up onto empty space" do

  end

  test "moving up and discovering an octopus" do

  end

  test "moving up and discovering an fish" do

  end

  test "moving up past actions" do

  end

  test "moving up past marked spaces" do
    
  end

  test "moving up past depth_zone" do

  end

  test "moving up past the top" do

  end

  test "moving back over a space with actions a second time" do

  end

  test "running out of stress" do

  end

  test "running out of damage" do

  end

  test "running out of oxygen" do

  end

end
