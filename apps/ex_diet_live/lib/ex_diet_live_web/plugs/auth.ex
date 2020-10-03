defmodule ExDietLiveWeb.Plugs.Auth do
  @moduledoc false

  import Plug.Conn
  import Phoenix.Controller
  alias ExDietLiveWeb.Router.Helpers, as: Routes

  def init(opts), do: opts

  def call(conn, :require_authenticated) do
    conn
    |> assign_current_user(get_session(conn, :user_id))
    |> check_authenticated()
  end

  def call(conn, :require_anonymous) do
    conn
    |> assign_current_user(get_session(conn, :user_id))
    |> check_anonymous()
  end

  def call(conn, _) do
    assign_current_user(conn, get_session(conn, :user_id))
  end

  defp assign_current_user(conn, nil) do
    conn
  end

  defp assign_current_user(conn, user_id) do
    case conn.assigns[:current_user] do
      %ExDiet.Accounts.User{} ->
        conn

      _ ->
        case ExDiet.Accounts.get_user(user_id) do
          nil ->
            clear_session(conn)

          %ExDiet.Accounts.User{} = user ->
            assign(conn, :current_user, user)
        end
    end
  end

  defp check_anonymous(%Plug.Conn{assigns: %{current_user: %ExDiet.Accounts.User{}}} = conn) do
    conn
    |> put_flash(:error, "You must be logged out to access that page")
    |> redirect(to: Routes.page_path(conn, :index))
    |> halt()
  end

  defp check_anonymous(%Plug.Conn{} = conn) do
    conn
  end

  defp check_authenticated(%Plug.Conn{assigns: %{current_user: %ExDiet.Accounts.User{}}} = conn) do
    conn
  end

  defp check_authenticated(%Plug.Conn{} = conn) do
    conn
    |> put_flash(:error, "You must be logged in to access that page")
    |> redirect(to: Routes.page_path(conn, :index))
    |> halt()
  end
end
