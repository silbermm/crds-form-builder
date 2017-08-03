defmodule MinistryPlatform do
  @moduledoc """
  Interact with Ministry Platform API
  """

  #TODO: better named variables
  #TODO: support configuration via {:system, ...}
  @username Application.get_env(:crds_form_builder, :api_username)
  @password Application.get_env(:crds_form_builder, :api_password)
  @host Application.get_env(:crds_form_builder, :api_host)
  @client_id Application.get_env(:crds_form_builder, :api_client_id)
  @client_secret Application.get_env(:crds_form_builder, :api_client_secret)

  @doc """
  Takes a map of Tables -> [ Fields ] and queries Ministry Platform for the 
  Data.
  """
  def form_data(mp_map) do
    {:ok, auth_token} = authenticate()
    mp_map
    |> Map.keys
    |> Enum.reduce(%{}, fn(table, acc) ->
      selectColumns  = mp_map
                       |> Map.get(table)
                       |> Enum.join(",")
      response = map_response(get(table, selectColumns, "Contact_ID=2186211", auth_token))
      Map.update(acc, table, [response], &(&1 ++ [response]))
    end)
  end

  @doc """
  Wrapper for the Ministry Platform GET Api call
  """
  def get(table, selectColumns, filter, auth_token) do
    HTTPoison.get(
      "#{@host}/ministryplatformapi/tables/#{table}?$select=#{selectColumns}&$filter=#{filter}",
      %{"Authorization" => "Bearer #{auth_token}"}
    )
  end

  @doc """
  Authenticate with Ministry Platform. 

  Returns a Token that can be used in subsequent calls to the API
  """
  def authenticate() do
    response = HTTPoison.post(
      "#{@host}/ministryplatform/oauth/token",
      get_auth_body,
      %{"Content-type" => "application/x-www-form-urlencoded"}
    )
    case response do
      {:ok, %HTTPoison.Response{"status_code": 200, "body": body}} ->
        token = Poison.Parser.parse!(body)
        {:ok, Map.get(token, "access_token")}
      _ = err ->
        {:error, "unable to authenticate"}
    end
  end

  @doc false
  defp get_auth_body do
    ["username=#{URI.encode(@username)}",
     "&password=#{@password}",
     "&client_id=#{@client_id}",
     "&client_secret=#{@client_secret}",
     "&grant_type=password"] |> Enum.join
  end

  defp map_response({:ok, %HTTPoison.Response{body: body, status_code: 200}} = response) do
    body
    |> Poison.decode!
    |> List.first
  end

  defp map_response(response), do: :error

end
