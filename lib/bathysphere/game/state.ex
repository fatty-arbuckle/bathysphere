defmodule Bathysphere.Game.State do

  defstruct [
    state: :ok, # :no_map, :complete, :dead,
    dice_pool_size: 0,
    dice_pool: [],
    map: [],
    position: 0,
    remaining: 0,
    score: 0,
    stress: [],
    damage: [],
    oxygen: [],
    fish_points: [],
    octopus_points: []
  ]

end
