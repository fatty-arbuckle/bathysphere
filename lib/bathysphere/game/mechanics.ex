defmodule Bathysphere.Game.Mechanics do

  def roll(game_state, :init) do
    new_state = %{ game_state | dice_pool: roll_dice(game_state.dice_pool_size) }
    { new_state.state, new_state }
  end
  def roll(game_state) do
    new_state = %{ game_state |
      dice_pool: roll_dice(game_state.dice_pool_size),
      oxygen: mark_resource(:oxygen, game_state.oxygen, 1)
    }
    |> evaluate_game
    { new_state.state, new_state }
  end

  def select_action(game_state, {{type, value, _used?} = action, _idx}) do
    { :space, %{ actions: actions } = data } = Enum.at(game_state.map, game_state.position)
    action_idx = Enum.find_index(actions, fn a ->
      action == a
    end)
    updated_actions = List.replace_at(actions, action_idx, {type, value, true})
    updated_space = { :space, %{ data | actions: updated_actions } }
    updated_game_state = %{ game_state |
      state: :ok,
      map: List.replace_at(game_state.map, game_state.position, updated_space)
    }
    updated_game_state = case type do
      :stress -> %{ updated_game_state | stress: mark_resource(:stress, updated_game_state.stress, abs(value)) }
      :damage -> %{ updated_game_state | damage: mark_resource(:damage, updated_game_state.damage, abs(value)) }
      :oxygen -> %{ updated_game_state | oxygen: mark_resource(:oxygen, updated_game_state.oxygen, abs(value)) }
    end
    updated_game_state = move(updated_game_state)
    {updated_game_state.state, updated_game_state}
  end

  def up(%{state: :ok, dice_pool: dice_pool} = game_state, n) do
    if Enum.member?(dice_pool, n) do
      updated = move(%{ game_state | remaining: n, direction: -1 })
      {updated.state, %{ updated | dice_pool: List.delete(dice_pool, n)}}
    else
      {:invalid_move, game_state}
    end
  end
  def up(%{state: state} = game_state, _n), do: {state, game_state}

  def down(%{state: :ok, dice_pool: dice_pool} = game_state, n) do
    if Enum.member?(dice_pool, n) do
      updated = move(%{ game_state | remaining: n, direction: +1 })
      {updated.state, %{ updated | dice_pool: List.delete(dice_pool, n)}}
    else
      {:invalid_move, game_state}
    end
  end
  def down(%{state: state} = game_state, _n), do: {state, game_state}


  defp roll_dice(n) do
    Enum.map(0..(n-1), fn _ -> :rand.uniform(6) end)
  end

  defp move(%{ remaining: 0 } = game_state) do
    game_state
  end
  defp move(%{state: {:select_action, _actions}} = game_state) do
    game_state
  end
  defp move(%{ remaining: remaining } = game_state) do
    case update_position(game_state) do
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
        game_state = evaluate(game_state)
        move(game_state)
    end
  end

  defp update_position(game_state) do
    bottom = Enum.count(game_state.map)
    if game_state.position + game_state.direction >= bottom or game_state.position + game_state.direction < 0 do
      {:out_of_bounds, game_state.position}
    else
      {:ok, game_state.position + game_state.direction}
    end
  end

  defp evaluate(game_state) do
    evaluate_space(
      Enum.at(game_state.map, game_state.position),
      game_state
    )
    |> evaluate_game
  end

  defp evaluate_space({:depth_zone, _}, %{ remaining: remaining } = game_state) do
    game_state = %{ game_state | stress: mark_resource(:stress, game_state.stress, abs(remaining + 1)) }
    # TODO special handling for depth_zone as bottom or top
    game_state = %{ game_state | remaining: remaining + 1 }
    move(game_state)
  end
  # landing on a marked space
  defp evaluate_space({:space, %{marked?: true}}, %{ remaining: 0 } = game_state) do
    %{ game_state | stress: mark_resource(:stress, game_state.stress, 1) }
  end
  # passing over a marked space
  defp evaluate_space({:space, %{marked?: true}}, game_state) do
    game_state
  end
  # landing on an unmarked space
  defp evaluate_space({:space, %{actions: _actions} = data}, %{ remaining: 0 } = game_state) do
    updated_space = {:space, %{ data | marked?: true }}
    updated_map = List.replace_at(game_state.map, game_state.position, updated_space)
    %{ game_state |
      map: updated_map
    }
  end
  # passing over an unmarked space
  defp evaluate_space({:space, %{actions: actions}}, game_state) do
    actions_remaining = Enum.with_index(actions)
    |> Enum.filter(fn {{type, _data, used?}, _idx} ->
      !used? and Enum.member?([:stress, :damage, :oxygen], type)
    end)
    apply_action(game_state, actions_remaining)
  end
  # passing by / landing on start (which is the finish)
  defp evaluate_space({:start, _}, game_state) do
    %{ game_state | state: :complete }
  end

  defp apply_action(game_state, nil), do: game_state
  defp apply_action(game_state, []), do: game_state
  defp apply_action(game_state, [ {{type, data, false}, idx} ]) do
    game_state = case type do
      :stress -> %{ game_state | stress: mark_resource(:stress, game_state.stress, abs(data)) }
      :damage -> %{ game_state | damage: mark_resource(:damage, game_state.damage, abs(data)) }
      :oxygen -> %{ game_state | oxygen: mark_resource(:oxygen, game_state.oxygen, abs(data)) }
    end
    {:space, space_data} = Enum.at(game_state.map, game_state.position)
    updated_actions = List.replace_at(space_data.actions, idx, {type, data, true})
    updated_space = {:space, %{ space_data | actions: updated_actions }}
    updated_map = List.replace_at(game_state.map, game_state.position, updated_space)
    %{ game_state | map: updated_map }
  end
  defp apply_action(game_state, actions) when is_list(actions) do
    %{ game_state |
      state: { :select_action, actions }
    }
  end

  defp mark_resource(_type, resources, 0), do: resources
  defp mark_resource(type, resources, data) do
    resources = [{type, true}] ++ Enum.drop(resources, -1)
    mark_resource(type, resources, data - 1)
  end

  defp evaluate_game(game_state) do
    game_state
    |> evaluate_resource(:stress)
    |> evaluate_resource(:damage)
    |> evaluate_resource(:oxygen)
    |> evaluate_points
    # TODO trigger actions based on state, like fewer dice or damage from stress
  end

  defp evaluate_resource(game_state, resource) do
    case Enum.any?(get_resource(game_state, resource), fn {_, used?} -> !used? end) do
      false ->
        %{ game_state | state: :dead }
      true ->
        game_state
    end
  end

  defp get_resource(game_state, :stress), do: game_state.stress
  defp get_resource(game_state, :damage), do: game_state.damage
  defp get_resource(game_state, :oxygen), do: game_state.oxygen

  defp evaluate_points(game_state) do
    {fish, octopus, points} = Enum.reduce(game_state.map, {0, 0, 0}, fn {space_type, data}, {fish, octopus, points} ->
      case space_type do
        :space ->
          case data.marked? do
            true ->
              f = Enum.filter(data.actions, fn {type, value, _used} ->
                type == :discovery and value == :fish
              end)
              |> Enum.count
              o = Enum.filter(data.actions, fn {type, value, _used} ->
                type == :discovery and value == :octopus
              end)
              |> Enum.count
              p = Enum.reduce(data.actions, 0, fn {type, value, _used}, acc ->
                if type == :ocean_floor, do: acc + value, else: acc
              end)
              {fish + f, octopus + o, points + p}
            _ ->
              {fish, octopus, points}
          end
        _ ->
          {fish, octopus, points}
      end
    end)

    # {fish, octopus, points}
    score = [
      Enum.take(game_state.fish_points, fish) |> Enum.sum(),
      Enum.take(game_state.octopus_points, octopus) |> Enum.sum(),
      points
    ]
    |> Enum.sum

    %{ game_state | score: score }
  end
end
