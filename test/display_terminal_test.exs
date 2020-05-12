defmodule DisplayTerminalTest do
  use ExUnit.Case

  test "displays the game_state" do
    expected = "Score: 0\n"
      <> "\n"
      <> "Oxygen: -X-  O₂ O₂ O₂ O₂\n"
      <> "Stress: -X- -X-  S  S  S  S  S \n"
      <> "Damage: -X-  D  D  D \n"
      <> "\n"
      <> " ↕️ |  Start / End   |\n"
      <> "   |     -1 O₂      |\n"
      <> "   |  -1 O₂ / -2 S  |\n"
      <> "   |                |\n"
      <> "   ◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆\n"
      <> "   |    Octopus     |\n"
      <> "   | XXXXXXXXXXXXXX |\n"
      <> "   |      -1 D      |\n"
      <> "   |    +2 Floor    |\n"

    game_state = %Bathysphere.Game.State{
      map: [
        { :start, %{} },
        { :space, %{ actions: [{:oxygen, -1}], marked?: false } },
        { :space, %{ actions: [{:oxygen, -1}, {:stress, -2}], marked?: false } },
        { :space, %{ actions: nil, marked?: false } },
        { :depth_zone, %{} },
        { :space, %{ actions: [{:discovery, :octopus}], marked?: false } },
        { :space, %{ actions: [], marked?: true } },
        { :space, %{ actions: [{:damage, -1}], marked?: false } },
        { :space, %{ actions: [{:ocean_floor, +2}], marked?: false } }
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
        Bathysphere.Display.Terminal.display(game_state)
      end)
  end
end
