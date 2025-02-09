defmodule Flamelex.Fluxus.UserInputHandler do
  use Flamelex.ProjectAliases
  alias Flamelex.Fluxus.Structs.RadixState
  require Logger




  # IN THE FUTURE - we route all input to the GUI.Controller
  # - this is the process which is able to understand the state of the GUI
  # (as it holds the "frame", "active_buffer" and other such things in it)
  # - 


  # # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :insert} = state, input) when input in @all_letters do
  # #   cursor_pos =
  # #     {:gui_component, state.active_buffer}
  # #     |> ProcessRegistry.find!()
  # #     |> GenServer.call(:get_cursor_position)


  # #   {:codepoint, {letter, _num}} = input

  # #   Buffer.modify(state.active_buffer, {:insert, letter, cursor_pos})

  # #   state |> RadixState.add_to_history(input)
  # # end

  # # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :insert} = state, input) do
  # #   Logger.debug "received some input whilst in :insert mode"
  # #   state |> RadixState.add_to_history(input)
  # # end


  #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: mode} = state, @escape_key) when mode in [:kommand, :insert] do
  #   #   Flamelex.API.CommandBuffer.deactivate()
  #   #   Flamelex.FluxusRadix.switch_mode(:normal)
  #   #   state |> RadixState.set(mode: :normal)
  #   # end

  #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :kommand} = state, input) when input in @valid_command_buffer_inputs do
  #   #   Flamelex.API.CommandBuffer.input(input)
  #   #   state
  #   # end

  #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :kommand} = state, @enter_key) do
  #   #   Flamelex.API.CommandBuffer.execute()
  #   #   Flamelex.API.CommandBuffer.deactivate()
  #   #   state |> RadixState.set(mode: :normal)
  #   # end


  #   # ## -------------------------------------------------------------------
  #   # ## Normal mode
  #   # ## -------------------------------------------------------------------

  #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :normal, active_buffer: nil} = state, input) do
  #   #   Logger.debug "received some input whilst in :normal mode, but ignoring it because there's no active buffer... #{inspect input}"
  #   #   state |> RadixState.add_to_history(input)
  #   # end

  #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :normal, active_buffer: active_buf} = state, input) do
  #   #   Logger.debug "received some input whilst in :normal mode... #{inspect input}"
  #   #   # buf = Buffer.details(active_buf)
  #   #   case KeyMapping.lookup_action(state, input) do
  #   #     :ignore_input ->
  #   #         state
  #   #         |> RadixState.add_to_history(input)
  #   #     {:apply_mfa, {module, function, args}} ->
  #   #         Kernel.apply(module, function, args)
  #   #         state |> RadixState.add_to_history(input)
  #   #   end
  #   # end

  #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :insert} = state, @enter_key = input) do
  #   #   cursor_pos =
  #   #     {:gui_component, state.active_buffer}
  #   #     |> ProcessRegistry.find!()
  #   #     |> GenServer.call(:get_cursor_position)

  #   #   Buffer.modify(state.active_buffer, {:insert, "\n", cursor_pos})

  #   #   state |> RadixState.add_to_history(input)
  #   # end

  #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :insert} = state, input) when input in @all_letters do
  #   #   cursor_pos =
  #   #     {:gui_component, state.active_buffer}
  #   #     |> ProcessRegistry.find!()
  #   #     |> GenServer.call(:get_cursor_position)


  #   #   {:codepoint, {letter, _num}} = input

  #   #   Buffer.modify(state.active_buffer, {:insert, letter, cursor_pos})

  #   #   state |> RadixState.add_to_history(input)
  #   # end

  #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :insert} = state, input) do
  #   #   Logger.debug "received some input whilst in :insert mode"
  #   #   state |> RadixState.add_to_history(input)
  #   # end




  #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :normal} = state, @lowercase_h) do
  #   #   Logger.info "Lowercase h was pressed !!"
  #   #   Flamelex.Buffer.load(type: :text, file: @readme)
  #   #   state
  #   # end

  #   # def handle_input(%Flamelex.Fluxus.Structs.RadixState{mode: :normal} = state, @lowercase_d) do
  #   #   Logger.info "Lowercase d was pressed !!"
  #   #   Flamelex.Buffer.load(type: :text, file: @dev_tools)
  #   #   state
  #   # end












  def handle(radix_state, {:user_input, ii}) do
    #Logger.debug "#{__MODULE__} handling some user input: #{inspect ii}"

    # spin up a process under the TaskSupervisor to do the lookup -
    # that process will then fire off any actions it needs to

    #NOTE: no need to await any callback from handling user input

    Task.Supervisor.start_child(
      Flamelex.Fluxus.InputHandler.TaskSupervisor,
          __MODULE__,                       # module
          :lookup_action_for_input_async,   # function
          [radix_state, ii]                 # args
    )
  end


  def lookup_action_for_input_async(%RadixState{mode: :memex} = radix_state, user_input) do
    #Logger.debug "#{__MODULE__} routing input received in Memex :mode."
    Flamelex.API.KeyMappings.Memex.keymap(radix_state, user_input)
    |> handle_lookup(radix_state)
  end

  #NOTE: this function is defined here, but it is run in it's own process...
  def lookup_action_for_input_async(%RadixState{mode: m} = radix_state, user_input)
    when m in [:normal, :insert] do
    Logger.debug "Async Process: lookup_action_for_input_async - #{inspect user_input}"

    #TODO just hard-code it for now, much easier...
    Flamelex.API.KeyMappings.VimClone.lookup(radix_state, user_input.input) #TODO here user_input still has all this shit in it (user_input.input <vomit>)
    |> handle_lookup(radix_state)

    # # IO.puts "#{__MODULE__} processing input... #{inspect event}"

    # #TODO key_mapping should be? a property of RadixState?
    # # key_mapping = Application.fetch_env!(:flamelex, :key_mapping)
    # key_mapping = Flamelex.API.KeyMappings.VimClone #TODO just hard-code it for now, much easier...

    # #TODO this should probably be a lookup inside the module?
    # #     or rather, maybe we pass the module into the lookup function?
    # 
    # case key_mapping.lookup(radix_state, user_input.input) do #TODO this is not grat, probably need to ditch the rest first
    #   nil ->
    #       _details = %{radix_state: radix_state, key_mapping: key_mapping, user_input: user_input}
    #       # Logger.warn "no KeyMapping found for recv'd user_input. #{inspect details, pretty: true}"
    #       :no_mapping_found
    #   :ok ->
    #       :ok
    #   :ignore_input ->
    #       :ok
    #   {:fire_action, a} ->
    #       Logger.debug " -- FIRING ACTION --> #{inspect a}"
    #       Flamelex.Fluxus.fire_action(a)

    #   #TODO deprecate it, just have 1 pattern match for vim_lang here
    #   {:vim_lang, x, v} ->
    #       GenServer.cast(Flamelex.GUI.VimServer, {{x, v}, radix_state})
    #   {:vim_lang, v} ->
    #       GenServer.cast(Flamelex.GUI.VimServer, {v, radix_state})
    #   {:apply_mfa, {module, function, args}} ->
    #       apply_mfa(module, function, args)
    #   {:execute_function, f} when is_function(f) ->
    #       f.()
    # end
  end

  def handle_lookup(nil, _radix_state) do
    # _details = %{radix_state: radix_state, key_mapping: key_mapping, user_input: user_input}
    # Logger.warn "no KeyMapping found for recv'd user_input. #{inspect details, pretty: true}"
    :no_mapping_found
  end

  def handle_lookup(:ok, _radix_state), do: :ok

  def handle_lookup({:vim_lang, v}, radix_state) do
    GenServer.cast(Flamelex.GUI.VimServer, {v, radix_state})
  end

  def handle_lookup({:vim_lang, x, v}, radix_state) do
    GenServer.cast(Flamelex.GUI.VimServer, {{x, v}, radix_state})
  end

  def handle_lookup(:ok, _radix_state), do: :ok


  def handle_lookup({:execute_function, f}, _radix_state) when is_function(f) do
    f.()
  end

  def handle_lookup({:apply_mfa, {module, function, args}}, _radix_state) do
    apply_mfa(module, function, args)
  end

  def handle_lookup(:ignore_input, _radix_state), do: :ok

  def handle_lookup({:fire_action, a}, _radix_state) do
    Logger.debug " -- FIRING ACTION --> #{inspect a}"
    Flamelex.Fluxus.fire_action(a)
  end

  def handle_lookup({:fire_actions, action_list}, _radix_state)
    when is_list(action_list) and length(action_list) > 0 do
      action_list |> Enum.map(fn (m) -> 
        Flamelex.Fluxus.fire_action(m)
      end)
  end

#   case key_mapping.lookup(radix_state, user_input.input) do #TODO this is not grat, probably need to ditch the rest first
#   nil ->
#       _details = %{radix_state: radix_state, key_mapping: key_mapping, user_input: user_input}
#       # Logger.warn "no KeyMapping found for recv'd user_input. #{inspect details, pretty: true}"
#       :no_mapping_found
#   :ok ->
#       :ok
#   :ignore_input ->
#       :ok
#   {:fire_action, a} ->
#       Logger.debug " -- FIRING ACTION --> #{inspect a}"
#       Flamelex.Fluxus.fire_action(a)
#   {:fire_actions, action_list} when is_list(action_list) and length(action_list) > 0 ->
#       action_list |> Enum.map(fn (m) -> 
#         Flamelex.Fluxus.fire_action(m)
#     end)
#   #TODO deprecate it, just have 1 pattern match for vim_lang here
#   {:vim_lang, x, v} ->
#       GenServer.cast(Flamelex.GUI.VimServer, {{x, v}, radix_state})
#   {:vim_lang, v} ->
#       GenServer.cast(Flamelex.GUI.VimServer, {v, radix_state})
#   {:apply_mfa, {module, function, args}} ->
#       apply_mfa(module, function, args)
#   {:execute_function, f} when is_function(f) ->
#       f.()
# end


  #NOTE: Keep this wrapper, incase we ever want to re-visit the Exception
  #      catching stuff.
  defp apply_mfa(module, function, args) do
    Kernel.apply(module, function, args)
    # try do
    #   result = Kernel.apply(module, function, args)
    #   if result == :err_not_handled do
    #     IO.puts "Unable to find module/func/args: #{inspect module}, #{inspect function}, #{inspect args}"
    #   else
    #     result |> IO.inspect(label: "Apply_MFA") # this is so the result will show up in console...
    #   end
    # rescue
    #   _e in UndefinedFunctionError ->
    #     Flamelex.Utilities.TerminalIO.red("Mod: #{inspect module}\nFun: #{inspect function}\nArg: #{inspect args}\n\nnot found.\n\n")
    #     |> IO.puts()
    #   e ->
    #     raise e
    # end
  end

end
