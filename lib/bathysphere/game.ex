defmodule Bathysphere.Game do
  use Supervisor

  def start_link(spaces) do
    GenServer.start_link(__MODULE__, spaces, name: __MODULE__)
  end

  def map do
    GenServer.call(__MODULE__, :map)
  end

  def position do
    GenServer.call(__MODULE__, :position)
  end

  def up do
    GenServer.cast(__MODULE__, :up)
  end

  def down do
    GenServer.cast(__MODULE__, :down)
  end

  def init(spaces) do
    {
      :ok,
      %{
        map: spaces,
        position: 0
      }
    }
  end

  def handle_call(:map, _from, %{map: map} = state) do
    {:reply, map, state}
  end

  def handle_call(:position, _from, %{position: position} = state) do
    {:reply, position, state}
  end

  def handle_cast(:up, %{map: map, position: position} = state) do
    position = update_position(-1, map, position)
    {:noreply, %{ state | position: position}}
  end

  def handle_cast(:down, %{map: map, position: position} = state) do
    position = update_position(+1, map, position)
    {:noreply, %{ state | position: position}}
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
