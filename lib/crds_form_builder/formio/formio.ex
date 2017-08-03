defmodule FormIO do
  @moduledoc """
  Various functions that interact with FormIO and the FormIO data
  """

  @formio_url "https://crossroads.form.io/"
  @type form_response :: {:ok, map()} | {:error, number()}

  @doc """
  Given a FormIO Form Map, get data from the configured datasource
  and build a map of submission data.
  """
  def get_data_to_populate_form(formio_form) do
    flattened_components = formio_form
                           |> Map.get("components")
                           |> flatten_components()

    flattened_components
    |> extract_data_fields()
    |> MinistryPlatform.form_data
    |> build_submission_data(flattened_components)
    |> Poison.encode!
  end

  #TODO: consider taking a keyword list of arguments
  @doc """
  Check if the form exists in FormIO based on the path given.
  The base url should be defined in your configuration file as 
  `TODO: add config parameter`

  Returns a Map of the form data as described in the 
  [FormIO api](https://documenter.getpostman.com/view/684631/formio-api/2Jvuks#541bacdc-2e3d-b76a-f00e-e67a5755ee0c)
  """
  @spec form_exists(String.t) ::form_response
  def form_exists(form_path) do
    form_exists(@formio_url, form_path)
  end

  @doc """
  Check if the for exists in FormIO based on the base_url and  path given.

  Returns a Map of the form data as described in the 
  [FormIO api](https://documenter.getpostman.com/view/684631/formio-api/2Jvuks#541bacdc-2e3d-b76a-f00e-e67a5755ee0c)
  """
  @spec form_exists(String.t, String.t) :: form_response
  def form_exists(base_url, form_path) do
    url = base_url <> form_path
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        { :ok, Poison.decode!(body) }
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, status_code}
      {:error, %HTTPoison.Error{reason: _reason}} ->
        {:error, 500}
    end
  end

  @doc """
  Builds a map of data to give the frontend which will prepopulate the
  form.
  """
  @spec build_submission_data(map(), list(map())) :: map()
  def build_submission_data(form_data, components_list) do
    # get the field where the mp_field == form_data key
    data = Enum.reduce(components_list, %{}, fn (component, acc) ->
      with %FormIO.Data{table: table, field: field} <- field(component) do
        field_name = Map.get(component, "key")
        value = form_data
                |> Map.get(table, [])
                |> List.first
                |> form_field_value(field)
        Map.put(acc, field_name, value)
     else
       _ -> acc
     end
    end)
    %{ "data" => data }
  end

  @doc """
  Given the components map from Form.IO's form object, looks
  through each component and finds the ones that have "data_field"
  and "data_table" keys in the "properties". 

  Returns a map where the keys are the tables and the values
  are a list of fields in the table.

  ## Examples

    iex> FormIO.extract_data_fields([%{"defaultValue" => "",
    ...> "inputType" => "text", "key" => "firstname", 
    ...> "label" => "First Name",
    ...> "placeholder" => "First Name", "prefix" => "",
    ...> "properties" => %{"data_field" => "First_Name",
    ...> "data_table" => "Contacts"},
    ...> "type" => "textfield"},
    ...> %{"action" => "submit", "block" => false, 
    ...> "disableOnInvalid" => false, "input" => true, 
    ...> "key" => "submit", "label" => "Submit" }])
    %{"Contacts" => ["First_Name"]}

  """
  @spec extract_data_fields(list(map())) :: map()
  def extract_data_fields(components) do
    IO.inspect components
    Enum.reduce(components, %{}, fn(component, acc) -> 
      with %FormIO.Data{table: table, field: field} <- field(component) do
        Map.update(acc, table, [field], &( &1 ++ [field]))
      else
        err -> acc
      end
    end)
  end

  @doc """
  FormIO has nests the form components many times. This function will take 
  the top level and component and recursivly enumerate through it to build
  an array of un-nested components.
  """
  @spec flatten_components(list(map())) :: list(map())
  def flatten_components(components) do
    Enum.map(components, fn(comp) ->
      flatten(comp)
    end)
    |> List.flatten
  end

  @doc false
  defp flatten(%{"columns" => columns}) do
    flatten(columns)
  end
  defp flatten(%{"components" => components}) do
    flatten(components)
  end
  defp flatten(%{"rows" => rows}) do
    flatten(rows)
  end
  defp flatten(component) when is_list(component) do
    Enum.map(component, fn(c) -> flatten(c) end)
  end
  defp flatten(component) do
    component
  end

  defp field(%{"properties" => %{ "data_table" => table,
    "data_field" => field,
    "data_lookup_table" => lookup_table,
    "data_lookup_field_id" => lookup_field_id,
    "data_lookup_field_name" => lookup_field_name
  }}) do
    %FormIO.Data{table: table, field: field, lookup_table: lookup_table,
      lookup_field_id: lookup_field_id, lookup_field_name: lookup_field_name}
  end
  defp field(%{"properties" => %{ "data_table" => table, "data_field" => field}}) do
    %FormIO.Data{table: table, field: field}
  end
  defp field(properties) do
    nil
  end

  defp form_field_value(:error, _fieldName), do: ""
  defp form_field_value(field_map, field_name), do: Map.get(field_map, field_name)
end
