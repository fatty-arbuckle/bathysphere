defmodule Bathysphere do

  def display, do: Bathysphere.Display.Terminal.display(Bathysphere.Game.map, Bathysphere.Game.position)
  def up, do: Bathysphere.Game.up
  def down, do: Bathysphere.Game.down

end
