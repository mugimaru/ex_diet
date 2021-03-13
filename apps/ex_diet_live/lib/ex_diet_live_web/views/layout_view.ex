defmodule ExDietLiveWeb.LayoutView do
  use ExDietLiveWeb, :view

  def navbar_pages do
    %{
      "Dashboard" => Routes.dashboard_path(ExDietLiveWeb.Endpoint, :index),
      "Ingredients" => Routes.ingredient_path(ExDietLiveWeb.Endpoint, :index),
      "Recipes" => Routes.recipe_path(ExDietLiveWeb.Endpoint, :index)
    }
  end

  def navbar_link(conn, title, path, opts \\ []) do
    active = if active_nav?(conn, path), do: "active", else: ""
    link(title, to: path, class: "nav-link #{active}", method: Keyword.get(opts, :method, :get))
  end

  defp active_nav?(conn, path) do
    nav_path =
      path
      |> String.replace(~r/\?.+\z/, "")
      |> String.split("/")
      |> Enum.reject(&(&1 == ""))

    if Enum.count(conn.path_info) < Enum.count(nav_path) do
      false
    else
      Enum.take(conn.path_info, Enum.count(nav_path)) == nav_path
    end
  end

  def gravatar_url(email, size \\ 40) do
    hash = :crypto.hash(:md5, String.downcase(email)) |> Base.encode16() |> String.downcase()
    "https://www.gravatar.com/avatar/#{hash}?s=#{size}"
  end
end
