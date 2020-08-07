defmodule Franklin.Application do
  @moduledoc ~S(`Franklin` is a Memex & computation tool written in Elixir.)

  use Application
  require Logger

  @welcome_string ~s(Welcome to Franklin.

  * `help`         :: Get more help.)


  def start(_type, _args) do

    Logger.info @welcome_string

    children = [
      GUI.TopLevelSupervisor,
      Franklin.Buffer.Supervisor, #TODO get rid of Franklin at the start of the module names, why do we have that? (maybe benefits for IEx??)
      Franklin.Agent.TopLevelSupervisor
    ]

    opts = [strategy: :one_for_one, name: Franklin.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
