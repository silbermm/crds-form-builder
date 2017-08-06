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
  Wrapper for the Ministry Platform GET Api call
  Takes optional keyword list of options:
    `[ select: "The_columns_to_select",
       filter: "The filter to apply",
       etc...
     ]`
  """
  def get(table, auth_token, opts) do
    Task.Supervisor.async(CrdsFormBuilder.TaskSupervisor, fn ->
      string_opts = opts
                    |> Keyword.keys
                    |> Enum.reduce("", fn(key, acc) ->
                      val = opts |> Keyword.get(key)
                      acc <> "&$#{key}=#{val}"
                    end)
      HTTPoison.get(
        "#{@host}/ministryplatformapi/tables/#{table}?#{string_opts}",
        %{"Authorization" => "Bearer #{auth_token}"})
      |> map_response
    end)
  end
  def get(table, auth_token) do
    Task.Supervisor.async(CrdsFormBuilder.TaskSupervisor, fn ->
      HTTPoison.get(
        "#{@host}/ministryplatformapi/tables/#{table}",
        %{"Authorization" => "Bearer #{auth_token}"})
      |> map_response
    end)
  end

  @doc """
  Takes the Http response from making a Ministry Platform rest call and tries to decode it
  into a map or list of maps. If the result of the Http call is an error, returns an :error.
  """
  @spec map_response({:ok, HTTPoison.Response.t} | {:error, HTTPoison.Error}) :: map() | list() | :error
  def map_response({:ok, %HTTPoison.Response{body: body, status_code: 200}}) do
    body
    |> Poison.decode!
    |> List.first
  end
  def map_response(_response), do: :error

  @doc """
  Authenticate with Ministry Platform.
  Returns a Token that can be used in subsequent calls to the API
  """
  def authenticate() do
    response = HTTPoison.post(
      "#{@host}/ministryplatform/oauth/token",
      get_auth_body(),
      %{"Content-type" => "application/x-www-form-urlencoded"}
    )
    case response do
      {:ok, %HTTPoison.Response{"status_code": 200, "body": body}} ->
        token = Poison.Parser.parse!(body)
        {:ok, Map.get(token, "access_token")}
      _ = _err ->
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
end
