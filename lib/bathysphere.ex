defmodule Bathysphere do

  def display do
    Bathysphere.Display.Terminal.display(Bathysphere.Game.state)
  end

  def up(n), do: Bathysphere.Game.up(n)
  def down(n), do: Bathysphere.Game.down(n)

end
