defmodule ExDietLiveWeb.LayoutViewTest do
  use ExDietLiveWeb.ConnCase, async: true
  alias ExDiet.Accounts.User
  alias ExDietLiveWeb.LayoutView
  alias ExDietLiveWeb.Router.Helpers, as: Routes

  defp navbar_pages_from_html(html) do
    html
    |> Floki.parse_document!()
    |> Floki.find("a")
    |> Enum.into(%{}, &{Floki.text(&1), hd(Floki.attribute(&1, "href"))})
  end

  describe ".render_navbar/2" do
    test "renders page links and logout nav for authenticated user" do
      html =
        build_conn()
        |> Plug.Conn.assign(:current_user, %User{id: 1, email: "foo@bar.com"})
        |> LayoutView.render_navbar()
        |> Phoenix.HTML.safe_to_string()

      assert Map.put(LayoutView.navbar_pages(), "Logout", Routes.account_session_path(ExDietLiveWeb.Endpoint, :delete)) ==
               navbar_pages_from_html(html)
    end

    test "renders login nav for an anonymous user" do
      html =
        build_conn()
        |> LayoutView.render_navbar()
        |> Phoenix.HTML.safe_to_string()

      assert %{"Login" => Routes.account_session_path(ExDietLiveWeb.Endpoint, :new)} == navbar_pages_from_html(html)
    end
  end

  # When testing helpers, you may want to import Phoenix.HTML and
  # use functions such as safe_to_string() to convert the helper
  # result into an HTML string.
  # import Phoenix.HTML
end
