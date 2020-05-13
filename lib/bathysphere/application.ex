defmodule Bathysphere.Application do

  use Application

  # spaces are {type, data, used?}
  @spaces [
    { :start, %{} },
    { :space, %{ actions: [{:oxygen, -1, false}], marked?: false } },
    { :space, %{ actions: [{:oxygen, -1, false}, {:stress, -2, false}], marked?: false } },
    { :space, %{ actions: [], marked?: false } },
    { :depth_zone, %{} },
    { :space, %{ actions: [{:discovery, :octopus, false}], marked?: false } },
    { :space, %{ actions: [], marked?: false } },
    { :space, %{ actions: [{:damage, -1, false}], marked?: false } },
    { :space, %{ actions: [{:ocean_floor, +2, false}], marked?: false } }
  ]

  @oxygen Enum.map(0..4, fn _ -> {:oxygen, false} end)
  @stress Enum.map(0..6, fn _ -> {:stress, false} end)
  @damage Enum.map(0..3, fn _ -> {:damage, false} end)

  def start(_type, _args) do
    children = [
      { Bathysphere.Game,
        {
          @spaces,
          @oxygen,
          @stress,
          @damage,
        }
      }
    ]

    opts = [strategy: :one_for_one, name: Bathysphere.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
