defmodule ExDietLiveWeb.Food.IngredientLiveTest do
  use ExDiet.DataCase
  use ExDietLiveWeb.ConnCase
  import Phoenix.LiveViewTest

  test "redirects anonymous user", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/"}}} = live(conn, Routes.ingredient_path(@endpoint, :index))
  end

  @tag authenticated: true
  test "renders page for authenticated user", %{conn: conn} do
    {:ok, _view, html} = conn |> get(Routes.ingredient_path(@endpoint, :index)) |> live()
    assert html =~ "ingredients"
  end
end
