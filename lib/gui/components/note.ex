defmodule GUI.Component.Note do
  @moduledoc false
  use Scenic.Component
  alias Scenic.Graph
  import Scenic.Primitives
  require Logger
  import Utilities.ComponentUtils

  @ibm_plex_mono GUI.Initialize.ibm_plex_mono_hash

  @title_prompt "New note..."
  @text_prompt "Press <TAB> to move to the text input area."

  def verify(%{
    id: _id,
    top_left_corner: {_x, _y},
    dimensions: {_w, _h},
    contents: %{
      title: _title,
      text: _text
    }
  } = data), do: {:ok, data}
  def verify(_), do: :invalid_data

  def info(_data), do: ~s(Invalid data)

  def handle_call({:register, identifier}, {pid, _ref}, {%{component_ref: ref_list} = state, graph}) do
    Process.monitor(pid)

    new_component = {identifier, pid}
    #TODO ensure new component registry is unique!
    Logger.info "#{__MODULE__} registering component: #{inspect new_component}..."
    new_ref_list = ref_list ++ [new_component]
    new_state = state |> Map.replace!(:component_ref, new_ref_list)

    {:reply, :ok, {new_state, graph}}
  end

  @doc false
  def init(%{
    id: id,
    top_left_corner: {x, y},
    dimensions: {width, height},
    contents: %{title: title, text: note_contents}
  } = data, _opts) do
    Logger.info "#{__MODULE__} initializing...#{inspect data}"
    title_text = if title == "", do: @title_prompt, else: title
    note_text = if note_contents == "", do: @text_prompt, else: title
    title_font_size = 48

    #TODO remove/hide cursor if focus leaves this window (or we go into command mode)
    #TODO if note crashes, Root needs to monitor it & remove it from it's component refs - but it's being restarted???

    graph =
      Graph.build()
      |> rect({width, height}, translate: {x, y}, fill: :cornflower_blue, stroke: {1, :ghost_white})
      |> text(title_text,
         id: :title,
         font: @ibm_plex_mono,
         translate: {x+15, y+title_font_size}, # text draws from bottom-left corner?? :( also, how high is it???
         font_size: title_font_size,
         fill: :black)
      |> add_cursor(data, title_font_size)
      |> line({{x+15, y+title_font_size+25}, {x+width-15, y+title_font_size+25}}, stroke: {3, :black})
      |> text(note_text,
         id: :text,
         font: @ibm_plex_mono,
         translate: {x+15, y+title_font_size+65}, # text draws from bottom-left corner?? :( also, how high is it???
         fill: :black)

    GenServer.call(GUI.Scene.Root, {:register, id})
    {:ok, {%{component_ref: []}, graph}, push: graph}
  end

  def handle_cast({'APPEND_INPUT_TO_TITLE', %{focus: :title, title: new_title}}, {state, graph}) do
    new_graph =
      graph |> Graph.modify(:title, &text(&1, new_title, fill: :black))

    find_component_reference_pid!(state.component_ref, :cursor)
    |> GUI.Component.Cursor.move_right_one_column()

    {:noreply, {state, new_graph}, push: new_graph}
  end

  defp add_cursor(graph, %{top_left_corner: {x, y}}, font_size) do
    {_x_min, _y_min, _x_max, y_max} =
      GUI.FontHelpers.get_max_box_for_ibm_plex(font_size)

    y_offset     = y+10
    y_box_buffer = 2 # it looks weird having box exact same size as the text
    x_coordinate = x+15
    y_coordinate = y_offset + y_box_buffer
    width        = GUI.FontHelpers.monospace_font_width(:ibm_plex, font_size)  #TODO should probably truncate this
    height       = y_max + y_box_buffer #TODO should probably truncate this

    graph
    |> GUI.Component.Cursor.add_to_graph(%{
          top_left_corner: {x_coordinate, y_coordinate},
          dimensions: {width, height},
          parent: %{pid: self()}
        })
  end

  defp find_cursor_pid(state) do

  end
end
