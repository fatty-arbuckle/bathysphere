defmodule Bathysphere do

  def display do
    Bathysphere.Display.Terminal.display(Bathysphere.Game.state)
  end

  def up, do: Bathysphere.Game.up(1)
  def down, do: Bathysphere.Game.down(1)

end
