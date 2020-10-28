defmodule Flamelex.OmegaMaster do
  @moduledoc """
  The OmegaMaster holds all global state, acts as a conduit for all
  user-input, and manages modes. We need a single junction-point where
  all the data required to make decisions can be combined & acted upon -
  this is it.

  All inputs get sent here, & then thrown into the Omega.Reducer (along with
  the OmegaState, which represents the global-variables for Flamelex).

  What belongs in the domain of OmegaState? Anything which affects both
  buffers & GUI components. e.g. opening the Command buffer requires:

  * changing the input mode
  * checking the contents of `Flamelex.Buffer.Command`
  * rendering the GUI.Component


  """
  use GenServer
  require Logger
  use Flamelex.ProjectAliases
  alias Flamelex.Structs.OmegaState


  def start_link(_params) do
    initial_state = OmegaState.init()
    GenServer.start_link(__MODULE__, initial_state)
  end

  def show(:command_buffer = x) do
    GenServer.cast(__MODULE__, {:show, x})
  end

  def hide(:command_buffer = x) do
    GenServer.cast(__MODULE__, {:hide, x})
  end

  @doc """
  This function handles user input. All input from the entire GUI routes
  through here.

  We use the state of the root scene (which may include global variables
  such as which mode we are in, and the recent input history, to allow
  chaining of keystrokes), as well as the input itself, to compute the new
  state, as well as fire off any secondary events or updates that this
  input requests.
  """
  def handle_input(input) do
    GenServer.cast(__MODULE__, {:handle_input, input})
  end

  @doc """
  This function enables us to fire actions off which enact changes, at
  the OmegaMaster level, but which aren't stricly responses to user input.
  """
  # def action(a) do
  #   GenServer.cast(__MODULE__, {:action, a})
  # end

  ## GenServer callbacks
  ## -------------------------------------------------------------------


  def init(%OmegaState{} = omega_state) do
    IO.puts "#{__MODULE__} initializing..."
    Process.register(self(), __MODULE__)
    {:ok, omega_state}
  end



  def handle_cast({:handle_input, input}, omega_state) do

    #REMINDER: actions may be pushed down to other buffers
    #          by Flamelex.Omega.Reducer
    new_omega_state =
        omega_state |> Flamelex.InputHandler.handle_input(input)

    {:noreply, new_omega_state}
  end



  #TODO maybe x will be worth considering eventually???
  def handle_cast({:show, :command_buffer}, omega_state) do
    IO.puts "SHOWING BUFF"
    case Buffer.read(:command_buffer) do
      data when is_bitstring(data) ->
        #TODO so this should then be responsible for managing the buffer process (starting/stopping/finding if sleeping) nd causing it to refresh, whilst also making it visible by forcing a redraw
        # GUI.Controller.show({:command_buffer, data})
        Flamelex.GUI.Component.CommandBuffer.show()
        {:noreply, %{omega_state|mode: :command}}
      e ->
        raise "Unable to read Buffer.Command. #{inspect e}"
    end
  end

  def handle_cast({:hide, :command_buffer}, omega_state) do
    # GUI.Controller.hide(:command_buffer)
    Flamelex.GUI.Component.CommandBuffer.hide()
    {:noreply, %{omega_state|mode: :normal}}
  end

  # def handle_cast({:action, a}, omega_state) do
  #   new_omega_state =
  #     omega_state
  #     # |> Flamelex.Omega.Reducer.process_action(a)

  #   {:noreply, new_omega_state}
  # end
end
