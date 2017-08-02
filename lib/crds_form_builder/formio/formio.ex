defmodule FormIO do

  @formio_url "https://mmpdfuvrztkytaa.form.io/"

  def form_exists(form_path) do
    url = @formio_url <> form_path
    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        { :ok, Poison.decode!(body) }
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        {:error, status_code}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, 500}
    end
  end

end
