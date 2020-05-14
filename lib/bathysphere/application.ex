defmodule Bathysphere.Application do

  use Application

  def start(_type, _args) do
    children = [
      { Bathysphere.Game, {} }
    ]

    opts = [strategy: :one_for_one, name: Bathysphere.Supervisor]
    Supervisor.start_link(children, opts)
  end

end
