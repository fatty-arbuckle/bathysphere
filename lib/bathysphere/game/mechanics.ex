defmodule Bathysphere.Game.Mechanics do

  def up(%{state: :ok} = game_state, n) do
    updated = move(-1, %{ game_state | remaining: n })
    {updated.state, updated}
  end
  def up(%{state: state} = game_state, _n), do: {state, game_state}

  def down(%{state: :ok} = game_state, n) do
    updated = move(+1, %{ game_state | remaining: n })
    {updated.state, updated}
  end
  def down(%{state: state} = game_state, _n), do: {state, game_state}

  defp move(_inc, %{ remaining: 0 } = game_state) do
    game_state
  end
  defp move(inc, %{ remaining: remaining } = game_state) do
    case update_position(inc, game_state) do
      {:out_of_bounds, position} ->
        # TODO apply penalty for out_of_bounds?
        {:space, data} = Enum.at(game_state.map, position)
        updated_space = {:space, %{ data | marked?: true }}
        updated_map = List.replace_at(game_state.map, position, updated_space)
        %{ game_state |
          map: updated_map,
          position: position,
          remaining: 0,
          stress: mark_resource(:stress, game_state.stress, remaining)
        }
      {:ok, new_position} ->
        game_state = %{ game_state |
          position: new_position ,
          remaining: remaining - 1
        }
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

  defp evaluate(inc, game_state) do
    evaluate_space(
      Enum.at(game_state.map, game_state.position),
      inc,
      game_state
    )
    |> evaluate_game
  end

  defp evaluate_space({:depth_zone, _}, inc, %{ remaining: remaining } = game_state) do
    game_state = %{ game_state | stress: mark_resource(:stress, game_state.stress, abs(remaining + 1)) }
    # TODO special handling for depth_zone as bottom or top
    game_state = %{ game_state | remaining: remaining + 1 }
    move(inc, game_state)
  end
  # landing on a marked space
  defp evaluate_space({:space, %{marked?: true}}, _inc, %{ remaining: 0 } = game_state) do
    %{ game_state | stress: mark_resource(:stress, game_state.stress, 1) }
  end
  # passing over a marked space
  defp evaluate_space({:space, %{marked?: true}}, _inc, game_state) do
    game_state
  end
  # landing on an unmarked space
  defp evaluate_space({:space, %{actions: actions} = data}, _inc, %{ remaining: 0, fish_discovered: fish, octopus_discovered: octopus  } = game_state) do
    fish = Enum.reduce(actions, fish, fn {action, type, _used?}, acc ->
      if action == :discovery and type == :fish, do: acc + 1, else: acc
    end)
    octopus = Enum.reduce(actions, octopus, fn {action, type, _used?}, acc ->
      if action == :discovery and type == :octopus, do: acc + 1, else: acc
    end)
    updated_space = {:space, %{ data | marked?: true }}
    updated_map = List.replace_at(game_state.map, game_state.position, updated_space)
    %{ game_state |
      map: updated_map,
      fish_discovered: fish,
      octopus_discovered: octopus
    }
  end
  # passing over an unmarked space
  defp evaluate_space({:space, %{actions: actions} = space_data}, _inc, game_state) do
    Enum.with_index(actions)
    |> Enum.reduce(game_state, fn {{type, data, used?}, idx}, acc ->
      if used? do
        acc
      else
        acc = case type do
          :stress -> %{ acc | stress: mark_resource(:stress, acc.stress, abs(data)) }
          :damage -> %{ acc | damage: mark_resource(:damage, acc.damage, abs(data)) }
          :oxygen -> %{ acc | oxygen: mark_resource(:oxygen, acc.oxygen, abs(data)) }
          _ -> acc
        end
        updated_actions = List.replace_at(actions, idx, {type, data, true})
        updated_space = {:space, %{ space_data | actions: updated_actions }}
        updated_map = List.replace_at(acc.map, acc.position, updated_space)
        %{ acc | map: updated_map }
      end
    end)
  end
  # passing by / landing on start (which is the finish)
  defp evaluate_space({:start, _}, _inc, game_state) do
    %{ game_state | state: :complete }
  end

  defp mark_resource(_type, resources, 0), do: resources
  defp mark_resource(type, resources, data) do
    resources = [{type, true}] ++ Enum.drop(resources, -1)
    mark_resource(type, resources, data - 1)
  end

  defp evaluate_game(game_state) do
    game_state
    |> evaluate_stress
    |> evaluate_damage
    # out of oxygen?
    # out of stress?
    # out of damage?
    # TODO trigger actions based on state, like fewer dice or damage from stress
  end

  defp evaluate_stress(game_state) do
    case Enum.any?(game_state.stress, fn {_, used?} -> !used? end) do
      false ->
        %{ game_state | state: :dead }
      true ->
        game_state
    end
  end

  defp evaluate_damage(game_state) do
    case Enum.any?(game_state.damage, fn {_, used?} -> !used? end) do
      false ->
        %{ game_state | state: :dead }
      true ->
        game_state
    end
  end

end
