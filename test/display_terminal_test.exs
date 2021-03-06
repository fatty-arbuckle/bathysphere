defmodule DisplayTerminalTest do
  use ExUnit.Case

  test "displays the game_state" do
    expected = "Score: 0\n"
      <> "\n"
      <> "Oxygen: -X-  O₂ O₂ O₂ O₂\n"
      <> "Stress: -X- -X-  S  S  S  S  S \n"
      <> "Damage: -X-  D  D  D \n"
      <> "\n"
      <> "5 dice --> [ 3  5  1  -  - ]\n"
      <> "\n"
      <> " ↕️ |  Start / End   |\n"
      <> "   |     -1 O₂      |\n"
      <> "   |   - O₂ / - S   |\n"
      <> "   |                |\n"
      <> "   ◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆\n"
      <> "   |    Octopus     |\n"
      <> "   | XXXXXXXXXXXXXX |\n"
      <> "   |      -1 D      |\n"
      <> "   |    +2 Floor    |\n"

    game_state = %Bathysphere.Game.State{
      dice_pool_size: 5,
      dice_pool: [ 3, 5, 1 ],
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:oxygen, -1, false}], marked?: false } },
        { :space, %{ actions: [{:oxygen, -1, true}, {:stress, -2, true}], marked?: false } },
        { :space, %{ actions: nil, marked?: false } },
        { :depth_zone, %{} },
        { :space, %{ actions: [{:discovery, :octopus, nil}], marked?: false } },
        { :space, %{ actions: [], marked?: true } },
        { :space, %{ actions: [{:damage, -1, false}], marked?: false } },
        { :space, %{ actions: [{:ocean_floor, +2, false}], marked?: false } }
      ],
      position: 0,
      remaining: 0,
      score: 0,
      oxygen: [{:oxygen, true},{:oxygen, false},{:oxygen, false},{:oxygen, false},{:oxygen, false}],
      stress: [{:stress, true},{:stress, true},{:stress, false},{:stress, false},{:stress, false},{:stress, false},{:stress, false}],
      damage: [{:damage, true},{:damage, false},{:damage, false},{:damage, false}]
    }

    assert expected ==
      ExUnit.CaptureIO.capture_io(fn ->
        Bathysphere.Display.Terminal.display({game_state.state, game_state})
      end)
  end
end
