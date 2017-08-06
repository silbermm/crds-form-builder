defmodule CrdsFormBuilderWeb.SessionController do
  use CrdsFormBuilderWeb, :controller

  def login(conn, _params) do
    render conn, "login.html"
  end
end
