defmodule Flamelex.Application do
  @moduledoc false
  use Application
  require Logger


  def start(_type, _args) do

    Logger.debug "#{__MODULE__} initializing..."

    #TODO - eventually, we want to move to a centralized event-bus architecture
    # EventBus.register_topic(:general)

    children = [
      Flamelex.Fluxus.TopLevelSupervisor,
      Flamelex.Buffer.TopLevelSupervisor,
      Flamelex.GUI.TopLevelSupervisor
    ]

    opts = [strategy: :one_for_one, name: Flamelex.Trismegistus]
    Supervisor.start_link(children, opts)
  end

end
