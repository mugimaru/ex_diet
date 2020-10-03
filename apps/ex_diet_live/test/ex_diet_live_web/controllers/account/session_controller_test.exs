defmodule ExDietLiveWeb.Account.SessionControllerTest do
  use ExDiet.DataCase
  use ExDietLiveWeb.ConnCase

  alias ExDiet.Accounts

  describe "GET new" do
    test "renders login form" do
      conn = get(build_conn(), Routes.account_session_path(@endpoint, :new))
      assert Floki.parse_document!(conn.resp_body) |> Floki.find(~s/button[type="submit"]/) |> Floki.text() =~ "Login"
    end

    @tag authenticated: true
    test "redirects authenticated user", %{conn: conn} do
      conn = get(conn, Routes.account_session_path(@endpoint, :new))
      assert redirected_to(conn) =~ Routes.page_path(@endpoint, :index)
    end
  end

  describe "DELETE delete" do
    test "logs user out" do
      {:ok, user} = Accounts.create_user(%{email: "foo@bar.com", password: "supersecret"})

      conn = init_test_session(build_conn(), %{user_id: user.id})
      assert get_session(conn, :user_id) == user.id

      conn = delete(conn, Routes.account_session_path(@endpoint, :delete))
      assert get_session(conn, :user_id) == nil
    end
  end

  describe "POST create" do
    test "logs user in" do
      {:ok, user} = Accounts.create_user(%{email: "foo@bar.com", password: "supersecret"})

      conn =
        post(build_conn(), Routes.account_session_path(@endpoint, :create), %{
          "email" => user.email,
          "password" => "supersecret"
        })

      assert get_flash(conn, :info) == "Welcome Back!"
      assert get_session(conn, :user_id) == user.id
    end

    test "puts error flash when password does not match" do
      {:ok, user} = Accounts.create_user(%{email: "foo@bar.com", password: "supersecret"})

      conn =
        post(build_conn(), Routes.account_session_path(@endpoint, :create), %{
          "email" => user.email,
          "password" => "foobar"
        })

      assert get_flash(conn, :error) == "Invalid Credentials"
    end

    test "puts error flash when user not found" do
      conn =
        post(build_conn(), Routes.account_session_path(@endpoint, :create), %{
          "email" => "foo@bar.com",
          "password" => "baz"
        })

      assert get_flash(conn, :error) == "Invalid Credentials"
    end
  end
end
