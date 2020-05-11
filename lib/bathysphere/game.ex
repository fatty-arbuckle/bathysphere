defmodule Bathysphere.Game do
  use Supervisor

  def start_link(spaces) do
    GenServer.start_link(__MODULE__, spaces, name: __MODULE__)
  end

  def state do
    GenServer.call(__MODULE__, :state)
  end

  def up(n) do
    GenServer.cast(__MODULE__, {:up, n})
  end

  def down(n) do
    GenServer.cast(__MODULE__, {:down, n})
  end

  def init({spaces, oxygen, stress, damage}) do
    { :ok,
      %Bathysphere.Game.State{
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

  def handle_cast({:up, n}, state) do
    state = state
    |> Bathysphere.Game.Mechanics.up(n)
    {:noreply, state}
  end

  def handle_cast({:down, n}, state) do
    state = state
    |> Bathysphere.Game.Mechanics.down(n)
    {:noreply, state}
  end

end
