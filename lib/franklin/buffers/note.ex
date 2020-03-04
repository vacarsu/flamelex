defmodule Franklin.Buffer.Note do
  @moduledoc false
  use GenServer
  require Logger

  def start_link(contents) do
    GenServer.start_link(__MODULE__, contents)
  end


  ## GenServer callbacks
  ## -------------------------------------------------------------------


  @impl true
  def init(contents) do
    Logger.info "#{__MODULE__} initializing... #{inspect contents}"
    GUI.Scene.Root.action({'NEW_NOTE_COMMAND', contents})
    {:ok, contents}
  end
end
