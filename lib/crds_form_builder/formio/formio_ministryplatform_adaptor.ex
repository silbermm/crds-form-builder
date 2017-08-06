defmodule FormIO.MinistryPlatform.Adaptor do
  @behaviour FormIO.Adaptor
  alias MinistryPlatform

  @doc """
  Takes a map of Tables -> [ Fields ] and queries Ministry Platform for the
  Data.
  """
  def fetch_field_data(form_data) do
    {:ok, auth_token} = MinistryPlatform.authenticate()
    form_data
    |> Map.keys
    |> Enum.reduce(%{}, fn(table, acc) ->
      select_columns  = form_data
                       |> Map.get(table)
                       |> Enum.map(&(&1.name))
                       |> Enum.join(",")
      response = table
                 |> MinistryPlatform.get(auth_token,
                                         select: select_columns,
                                         filter: "Contact_ID=2186211")
      Map.update(acc, table, [response], &(&1 ++ [response]))
    end)
    |> resolve_tasks
  end

  defp resolve_tasks(map) do
    map
    |> Map.keys
    |> Enum.reduce(%{}, fn(table, acc) -> 
      resolves = map
                 |> Map.get(table)
                 |> Task.yield_many
                 |> Enum.map(&filter_task/1)
      Map.put(acc, table, resolves)
    end)
  end

  defp filter_task({t, {:ok, term}}), do: term
  defp filter_task(_), do: :error
end
