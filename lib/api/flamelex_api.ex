defmodule Flamelex do
  @moduledoc """
  The main interface to the Flamelex application.
  """
  use Flamelex.ProjectAliases


  @doc """
  `Know Thyself`

  Use this function to recompile, reload and restart the `Flamelex` application.

  https://www.youtube.com/watch?v=kl0rqoRbzzU

  Flamelex is an interactive thinking-space. It is intended to be edited
  on by the user, and incorporate changes to it's own codebase. It is a
  more refined version of the original Lisp machine. When you make
  changes in your Flamelex code/environment (try to start thinking of those
  two as the same thing), sometimes you need to (safely!) shut-down the
  application & restart it, without losing any state. That is what this
  function is for. Except the keeping state part, that doesn't work yet!
  """
  def temet_nosce do
    IO.puts "\n#{__MODULE__} stopping..."
    Application.stop(:flamelex)

    IO.puts "\n#{__MODULE__} recompiling..."
    IEx.Helpers.recompile

    IO.puts "\n#{__MODULE__} starting...\n"
    Application.start(:flamelex)
  end

  def redraw_gui do
    # shuts down scenc, starts it & gets GUI controller to attempt to re-draw
    # from scratch
    raise "not implemented"
  end


  @doc """
  #TODO
  Increase or decrease the logging output of Flamelex during runtime.
  """
  def set_log_level(:debug) do
    raise "How do I set the log level??"
  end


  @doc """
  Trigger help for the user.
  """
  def help do
    raise "no help to be found :("
  end
end
