defmodule Bathysphere.Game.Mechanics do

  def up(game_state, n) do
    IO.inspect(n, label: "up")
    move(-1, %{ game_state | remaining: n })
  end

  def down(game_state, n) do
    IO.inspect(n, label: "down")
    move(+1, %{ game_state | remaining: n })
  end

  defp move(_inc, %{ remaining: 0 } = game_state) do
    game_state
  end
  defp move(inc, %{ remaining: remaining } = game_state) do
    IO.inspect("moving from #{game_state.position}, #{remaining} left", label: "move")
    case update_position(inc, game_state) do
      {:out_of_bounds, position} ->
        IO.inspect("out_of_bounds", label: "move")
        # TODO apply penalty for out_of_bounds?
        %{ game_state | position: position }
      {:ok, new_position} ->
        game_state = %{ game_state |
          position: new_position ,
          remaining: remaining - 1
        }
        IO.inspect("moved to #{game_state.position}", label: "move")
        game_state = evaluate(inc, game_state)
        move(inc, game_state)
    end
  end

  defp update_position(inc, game_state) do
    bottom = Enum.count(game_state.map)
    if game_state.position + inc >= bottom or game_state.position + inc < 0 do
      {:out_of_bounds, game_state.position}
    else
      {:ok, game_state.position + inc}
    end
  end

  defp evaluate(inc, %{ remaining: remaining } = game_state) do
    IO.inspect("#{game_state.position}, #{remaining} left", label: "evaluate")
    evaluate_space(
      Enum.at(game_state.map, game_state.position),
      inc,
      game_state
    )
  end

  defp evaluate_space({:depth_zone, _}, inc, %{ remaining: remaining } = game_state) do
    # TODO special handling for depth_zone as bottom or top
    IO.inspect("depth_zone at #{game_state.position}", label: "evaluate")
    game_state = %{ game_state | remaining: remaining + 1 }
    move(inc, game_state)
  end
  # landing on a marked space
  defp evaluate_space({:space, %{marked?: true}}, _inc, %{ remaining: 0 } = game_state) do
    IO.inspect("costs on stress", label: "evaluate")
    # TODO apply stress reduction
    game_state
  end
  # passing over a marked space
  defp evaluate_space({:space, %{marked?: true}}, _inc, game_state) do
    IO.inspect("passing marked space", label: "evaluate")
    game_state
  end
  # landing on an unmarked space
  defp evaluate_space({:space, %{actions: _actions} = data}, _inc, %{ remaining: 0 } = game_state) do
    IO.inspect("land on space, applying actions", label: "evaluate")
    # TODO apply discovery actions
    IO.inspect("marking #{game_state.position}", label: "evaluate")
    updated_space = {:space, %{ data | marked?: true }}
    updated_map = List.replace_at(game_state.map, game_state.position, updated_space)
    %{ game_state | map: updated_map }
  end
  # passing over an unmarked space
  defp evaluate_space({:space, %{actions: _actions}}, _inc, game_state) do
    IO.inspect("passing space, applying actions", label: "evaluate")
    # TODO apply actions
    game_state
  end
  # passing by / landing on start (which is the finish)
  defp evaluate_space({:start, _}, _inc, game_state) do
    IO.inspect("finished game!", label: "evaluate")
    # TODO end game scenario
    game_state
  end


end
