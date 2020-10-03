defmodule ExDietLiveWeb.LayoutView do
  use ExDietLiveWeb, :view

  def render_navbar(conn, opts \\ []) do
    content_tag(:ul, class: Keyword.get(opts, :wrapper_class, ""), id: Keyword.get(opts, :wrapper_id, "")) do
      navs_for_user(conn, conn.assigns[:current_user])
    end
  end

  def navbar_pages do
    %{
      "Ingredients" => Routes.ingredient_path(ExDietLiveWeb.Endpoint, :index)
    }
  end

  defp navs_for_user(conn, nil) do
    [
      navbar_link(conn, "Login", Routes.account_session_path(conn, :new))
    ]
  end

  defp navs_for_user(conn, %ExDiet.Accounts.User{}) do
    pages = for {title, path} <- navbar_pages(), do: navbar_link(conn, title, path)
    pages ++ [navbar_link(conn, "Logout", Routes.account_session_path(conn, :delete), method: :delete)]
  end

  defp navbar_link(conn, title, path, opts \\ []) do
    class = if active_nav?(conn, path), do: "active", else: ""

    content_tag(:li, class: class) do
      link(title, to: path, method: Keyword.get(opts, :method, :get))
    end
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
end
