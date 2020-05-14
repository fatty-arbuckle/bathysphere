defmodule Bathysphere do

  def init(name) do
    case Bathysphere.Library.Games.load(name) do
      nil ->
        { :error, :game_not_found }
      game_state ->
        Bathysphere.Game.reset(game_state)
    end
  end

  def display do
    Bathysphere.Game.state
    |> Bathysphere.Display.Terminal.display
  end

  def up(n), do: Bathysphere.Game.up(n)

  def down(n), do: Bathysphere.Game.down(n)

end
