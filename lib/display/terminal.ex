defmodule Bathysphere.Display.Terminal do

  def display(game_state) do

    IO.puts "Score: #{game_state.score}\n"

    IO.puts display_oxygen(game_state.oxygen)
    IO.puts display_stress(game_state.stress)
    IO.puts display_damage(game_state.damage)
    IO.puts ""

    game_state.map
    |> Enum.with_index
    |> Enum.each(fn {space, index} ->
      display_space(space, index, game_state.position)
      |> IO.puts
    end)
  end

  defp display_oxygen(resources) do
    "Oxygen: " <>
    display_resource(resources)
  end
  defp display_stress(resources) do
    "Stress: " <>
    display_resource(resources)
  end
  defp display_damage(resources) do
    "Damage: " <>
    display_resource(resources)
  end

  defp display_resource([]), do: ""
  defp display_resource([{_token, true} | resources]), do: "-X- " <> display_resource(resources)
  defp display_resource([{token, false} | resources]), do: display_token(token) <> display_resource(resources)

  defp display_token(:oxygen), do: " O₂"
  defp display_token(:stress), do: " S "
  defp display_token(:damage), do: " D "



  defp display_space({:start, _ }, index, pos) do
    display_space_prefix(index, pos)
      <> "#{center("Start / End")}"
      <> display_boundry()
  end

  defp display_space({:space, %{ marked?: true }}, index, pos) do
    display_space_prefix(index, pos)
      <> "#{center("XXXXXXXXXXXXXX")}"
      <> display_boundry()
  end

  defp display_space({:space, %{ actions: actions, marked?: false }}, index, pos) do
    display_space_prefix(index, pos)
      <> "#{center(Enum.join(display_actions(actions), " / "))}"
      <> display_boundry()
  end

  defp display_space({:depth_zone, _}, _index, _pos) do
    "   ◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆◆"
  end

  defp display_space_prefix(index, pos) do
    " "
      <> display_position(index, pos)
      <> " "
      <> display_boundry()
  end

  defp display_boundry, do: "|"

  defp display_position(index, pos) when index == pos, do: "↕️"
  defp display_position(_, _), do: " "

  defp display_actions(nil), do: []
  defp display_actions([{:stress, value, used?} | tail]),
    do: ["#{display_action_value(value, used?)} S"] ++ display_actions(tail)
  defp display_actions([{:oxygen, value, used?} | tail]),
    do: ["#{display_action_value(value, used?)} O₂"] ++ display_actions(tail)
  defp display_actions([{:damage, value, used?} | tail]),
    do: ["#{display_action_value(value, used?)} D"] ++ display_actions(tail)
  defp display_actions([{:ocean_floor, value, used?} | tail]),
    do: ["#{display_action_value(value, used?)} Floor"] ++ display_actions(tail)
  defp display_actions([{:discovery, animal, _} | tail]),
    do: ["#{display_discovery(animal)}"] ++ display_actions(tail)
  defp display_actions([]),
    do: []

  defp display_action_value(value, false) when value > 0, do: "+#{value}"
  defp display_action_value(value, true) when value > 0, do: "-"
  defp display_action_value(value, false), do: "#{value}"
  defp display_action_value(_value, true), do: "-"

  defp display_discovery(:octopus), do: "Octopus"
  defp display_discovery(:fish), do: "Fish"

  defp center(s, b \\ 16) do
    len = String.length(s)
    if len > b do
      s
    else
      pad = Kernel.trunc((b - String.length(s)) / 2)
      String.duplicate(" ", pad) <> s <> String.duplicate(" ", b - len - pad)
    end
  end

end
