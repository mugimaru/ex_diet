defmodule ExDietLiveWeb.Account.RegistrationController do
  use ExDietLiveWeb, :controller

  def new(conn, _params) do
    render(conn, "new.html", email: nil, password: nil)
  end

  def create(conn, %{"email" => email, "password" => password}) do
    case ExDiet.Accounts.create_user(%{email: email, password: password}) do
      {:ok, user} ->
        conn
        |> put_session(:user_id, user.id)
        |> configure_session(renew: true)
        |> put_flash(:info, "Welcome, #{inspect(email)}!")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Error creating an account. Maybe #{inspect(email)} is already registered?")
        |> render("new.html", email: email, password: password)
    end
  end
end
