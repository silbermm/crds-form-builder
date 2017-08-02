defmodule CrdsFormBuilderWeb.PageController do
  use CrdsFormBuilderWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
