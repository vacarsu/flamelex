defmodule Flamelex.GUI.Structs.GUIState do
  @moduledoc """
  Struct which holds the state of the `Flamelex.GUI.Controller`.

  ## A quick note on modes

  Resist the temptation to put a mode here! I have tried it, and it is a
  bad idea. If you find yourself leaning that way, look to put the functionality
  in the FluxusRadix instead. The GUI has no modes - only the application.

  GUI very simply module, with big warm fuzzy secret job - it just renders
  the GUI.
  """
  use Flamelex.ProjectAliases


  defstruct [
    viewport: nil, # %Dimensions{},
      layout: nil, # %Layout{},
       graph: nil, # %Scenic.Graph{}
  ]


  @doc """
  Return the default initial state for the `Flamelex.GUI.Controller`
  """
  def initialize(%Dimensions{} = vp) do
    %__MODULE__{
      viewport: vp,
      layout: Layout.default(vp), #TODO so, each Layer, has a layout??
      graph: Scenic.Graph.build()
    }
  end
end
