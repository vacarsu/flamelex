defmodule Flamelex.Reminders do

  def ack(%Flamelex.Memex.Structs.Reminder{} = _reminder) do
    raise "Can't ack reminders yet!!"
  end

  # def ack_reminder(reminder = %__MODULE__{tags: old_tags}) when is_list(old_tags) do
  #   new_tags =
  #     old_tags
  #     |> Enum.reject(& &1 == "reminder")
  #     |> Enum.concat(["ackd_reminder"])

  #   reminder |> Map.replace!(:tags, new_tags)
  # end

end
