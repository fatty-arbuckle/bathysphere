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
    GenServer.call(__MODULE__, {:up, n})
  end

  def down(n) do
    GenServer.call(__MODULE__, {:down, n})
  end

  def reroll() do
    GenServer.call(__MODULE__, :reroll)
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
    { state, game_state } = Bathysphere.Game.Mechanics.roll(state, :init)
    {:reply, state, { state, game_state } }
  end

  def handle_call(:state, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:up, n}, _from, {_state, game_state}) do
    {reply, new_state} = Bathysphere.Game.Mechanics.up(game_state, n)
    {:reply, reply, {reply, new_state}}
  end

  def handle_call({:down, n}, _from, {_state, game_state}) do
    {reply, new_state} = Bathysphere.Game.Mechanics.down(game_state, n)
    {:reply, reply, {reply, new_state}}
  end

  def handle_call(:reroll, _from, {_state, game_state}) do
    {reply, new_state} = Bathysphere.Game.Mechanics.roll(game_state)
    {:reply, reply, {reply, new_state}}
  end

end
