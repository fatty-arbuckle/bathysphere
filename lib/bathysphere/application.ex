defmodule Bathysphere.Application do

  use Application

  @spaces [
    { :start, %{} },
    { :space, %{ actions: [{:oxygen, -1}], marked?: false } },
    { :space, %{ actions: [{:oxygen, -1}, {:stress, -2}], marked?: false } },
    { :space, %{ actions: nil, marked?: false } },
    { :depth_zone, %{} },
    { :space, %{ actions: [{:discovery, :octopus}], marked?: false } },
    { :space, %{ actions: [], marked?: false } },
    { :space, %{ actions: [{:damage, -1}], marked?: false } },
    { :space, %{ actions: [{:ocean_floor, +2}], marked?: false } }
  ]

  def start(_type, _args) do
    children = [
      { Bathysphere.Game,
        {
          @spaces,
          make(:oxygen, 4),
          make(:stress, 6),
          make(:damage, 3),
        }
      }
    ]

    opts = [strategy: :one_for_one, name: Bathysphere.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp make(token, n), do: Enum.map(0..n, fn _ -> {token, false} end)

end
