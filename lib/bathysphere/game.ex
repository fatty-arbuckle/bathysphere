defmodule Bathysphere.Game do
  use Supervisor

  def start_link(spaces) do
    GenServer.start_link(__MODULE__, spaces, name: __MODULE__)
  end

  def state do
    GenServer.call(__MODULE__, :state)
  end

  def up do
    GenServer.cast(__MODULE__, :up)
  end

  def down do
    GenServer.cast(__MODULE__, :down)
  end

  def init({spaces, oxygen, stress, damage}) do
    { :ok,
      %GameState{
        map: spaces,
        oxygen: oxygen,
        stress: stress,
        damage: damage
      }
    }
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_cast(:up, state) do
    {:noreply, %{ state | position: move(-1, state.map, state.position)}}
  end

  def handle_cast(:down, state) do
    {:noreply, %{ state | position: move(+1, state.map, state.position)}}
  end

  defp move(inc, map, position) do
    update_position(inc, map, position)
  end

  defp update_position(inc, map, position) do
    bottom = Enum.count(map)
    position = if position + inc >= bottom or position + inc < 0, do: position, else: position + inc
    if !test_position(Enum.at(map, position), :depth_zone) do
      position
    else
      update_position(inc, map, position)
    end
  end

  defp test_position(nil, :depth_zone), do: false
  defp test_position({type, _}, :depth_zone), do: type == :depth_zone

end
