defmodule ExDietWeb.PageController do
  use ExDietWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
