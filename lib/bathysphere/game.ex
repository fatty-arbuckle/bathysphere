defmodule Bathysphere.Game do
  use Supervisor

  def start_link(spaces) do
    GenServer.start_link(__MODULE__, spaces, name: __MODULE__)
  end

  # Resets the current game, and loads a new GameState
  def reset(%Bathysphere.Game.State{} = initial_state) do
    GenServer.call(__MODULE__, {:reset, initial_state})
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

  def init(_opt) do
    { :ok,
      {
        :ok,
        %Bathysphere.Game.State{
          state: :no_map
        }
      }
    }
  end

  def handle_call({:reset, state}, _from, _old_state) do
    game_state = Bathysphere.Game.Mechanics.roll(state, :init)
    {:reply, :ok, {game_state.state, game_state}}
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
