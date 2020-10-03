defmodule ExDietLiveWeb.Account.SessionController do
  use ExDietLiveWeb, :controller

  def new(conn, _params) do
    render(conn, "new.html", email: nil, password: nil)
  end

  def create(conn, %{"email" => email, "password" => password}) do
    case ExDiet.Accounts.login_with_password(email, password) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true)
        |> put_flash(:info, "Welcome Back!")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid Credentials")
        |> render("new.html", email: email, password: password)
    end
  end

  def delete(conn, _params) do
    conn
    |> clear_session()
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
