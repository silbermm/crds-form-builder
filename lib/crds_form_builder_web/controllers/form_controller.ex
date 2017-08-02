defmodule CrdsFormBuilderWeb.FormController do
  use CrdsFormBuilderWeb, :controller

  action_fallback CrdsFormBuilderWeb.FallbackController

  def index(conn, %{ "form_path" => form_path } = params) do
    form_path = Enum.join(form_path, "/")
    with { :ok, result } <- FormIO.form_exists(form_path) do
      IO.inspect(result)
      strResult = Poison.encode!(result)
      render conn, "index.html", form: result, strForm: strResult, form_path: form_path
    end
  end
end
