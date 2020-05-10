defmodule Bathysphere.Display.Terminal do

  def display(spaces, pos) do
    spaces
    |> Enum.with_index
    |> Enum.each(fn {space, index} ->
      display_space(space, index, pos)
      |> IO.puts
    end)
  end

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
  defp display_actions([{:stress, value} | tail]),
    do: ["#{display_action_value(value)} S"] ++ display_actions(tail)
  defp display_actions([{:oxygen, value} | tail]),
    do: ["#{display_action_value(value)} O₂"] ++ display_actions(tail)
  defp display_actions([{:damage, value} | tail]),
    do: ["#{display_action_value(value)} D"] ++ display_actions(tail)
  defp display_actions([{:ocean_floor, value} | tail]),
    do: ["#{display_action_value(value)} Floor"] ++ display_actions(tail)
  defp display_actions([{:discovery, animal} | tail]),
    do: ["#{display_discovery(animal)}"] ++ display_actions(tail)
  defp display_actions([]),
    do: []

  defp display_action_value(value) when value > 0, do: "+#{value}"
  defp display_action_value(value), do: "#{value}"

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
