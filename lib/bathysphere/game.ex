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

  def init({spaces, oxygen, stress, damage, fish_points, octopus_points}) do
    { :ok,
      {
        :ok,
        %Bathysphere.Game.State{
          map: spaces,
          oxygen: oxygen,
          stress: stress,
          damage: damage,
          fish_points: fish_points,
          octopus_points: octopus_points
        }
      }
    }
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_cast({:up, n}, {_state, game_state}) do
    {:noreply, Bathysphere.Game.Mechanics.up(game_state, n)}
  end

  def handle_cast({:down, n}, {_state, game_state}) do
    {:noreply, Bathysphere.Game.Mechanics.down(game_state, n)}
  end

end
