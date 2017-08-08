defmodule CrdsFormBuilderWeb.FallbackController do
  use CrdsFormBuilderWeb, :controller
  @dialyzer {:nowarn_function, call: 2}

  def call(conn, {:error, 404}) do
    conn
    |> put_status(:not_found)
    |> render(CrdsFormBuilderWeb.ErrorView, :"404")
  end
  def call(conn, {:error, 500}) do
    conn
    |> put_status(500)
    |> render(CrdsFormBuilderWeb.ErrorView, :"500")
  end
  def call(conn, {:error, status_code}) do
    conn
    |> put_status(500)
    |> render(CrdsFormBuilderWeb.ErrorView, :"500")
  end
  def call(conn, _params) do
    conn
    |> put_status(500)
    |> render(CrdsFormBuilderWeb.ErrorView, :"500")
  end
end
