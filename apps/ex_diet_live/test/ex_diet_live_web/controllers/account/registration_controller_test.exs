defmodule ExDietLiveWeb.Account.RegistrationControllerTest do
  use ExDiet.DataCase
  use ExDietLiveWeb.ConnCase

  alias ExDiet.Accounts

  describe "GET new" do
    test "renders registration form" do
      conn = get(build_conn(), Routes.account_registration_path(@endpoint, :new))

      assert Floki.parse_document!(conn.resp_body) |> Floki.find(~s/button[type="submit"]/) |> Floki.text() =~
               "Register"
    end

    @tag authenticated: true
    test "redirects authenticated user", %{conn: conn} do
      conn = get(conn, Routes.account_registration_path(@endpoint, :new))
      assert redirected_to(conn) =~ Routes.page_path(@endpoint, :index)
    end
  end

  describe "POST create" do
    test "creates an account and logs user in" do
      email = "foo@bar.com"

      conn =
        post(build_conn(), Routes.account_registration_path(@endpoint, :create), %{
          "email" => email,
          "password" => "supersecret"
        })

      assert get_flash(conn, :info) == "Welcome, #{inspect(email)}!"

      assert is_integer(get_session(conn, :user_id))
      assert ExDiet.Accounts.get_user!(get_session(conn, :user_id)).email == email
    end

    test "puts error flash when email is not unique" do
      {:ok, user} = Accounts.create_user(%{email: "foo@bar.com", password: "supersecret"})

      conn =
        post(build_conn(), Routes.account_registration_path(@endpoint, :create), %{
          "email" => user.email,
          "password" => "foobar"
        })

      assert get_flash(conn, :error) == "Error creating an account. Maybe #{inspect(user.email)} is already registered?"
    end
  end
end
