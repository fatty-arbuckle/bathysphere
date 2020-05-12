defmodule Bathysphere.Game.State do

  defstruct [
    map: [],
    position: 0,
    remaining: 0,
    score: 0,
    fish_discovered: 0,
    octopus_discovered: 0,
    stress: [],
    damage: [],
    oxygen: []
  ]

end
