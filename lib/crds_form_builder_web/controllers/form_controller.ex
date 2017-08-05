defmodule CrdsFormBuilderWeb.FormController do
  use CrdsFormBuilderWeb, :controller

  action_fallback CrdsFormBuilderWeb.FallbackController

  def index(conn, %{ "form_path" => form_path } = params) do
    form_path = Enum.join(form_path, "/")
    with { :ok, result } <- FormIO.form_exists(form_path) do
      submission_data = Task.await FormIO.get_data_to_populate_form(result)
      str_result = result |> Poison.encode |> encoded_result
      render conn, "index.html", form: result, str_form: str_result, form_path: form_path, submission_data: submission_data
    end
  end

  defp encoded_result({:ok, result}), do: result
  defp encoded_result(_), do: ""
end
