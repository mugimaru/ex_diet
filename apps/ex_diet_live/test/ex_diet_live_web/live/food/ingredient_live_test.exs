defmodule ExDietLiveWeb.Food.IngredientLiveTest do
  use ExDiet.DataCase
  use ExDietLiveWeb.ConnCase
  import ExDiet.Factory
  import Phoenix.LiveViewTest

  test "redirects anonymous user", %{conn: conn} do
    assert {:error, {:redirect, %{to: "/"}}} = live(conn, Routes.ingredient_path(@endpoint, :index))
  end

  @tag authenticated: true
  test "renders page for authenticated user", %{conn: conn} do
    {:ok, _view, html} = conn |> get(Routes.ingredient_path(@endpoint, :index)) |> live()
    assert html =~ "New ingredient"
  end

  @tag authenticated: true
  test "ingredient update", %{conn: conn, user: user} do
    ingredients = insert_list(10, :ingredient, user: user)
    {:ok, view, html} = get(conn, Routes.ingredient_path(@endpoint, :index)) |> live()

    for ingredient <- ingredients do
      assert html =~ ingredient.name
    end

    ing = hd(ingredients)

    assert view |> element("#ingredient-#{ing.id}") |> render_click() =~ "Update ingredient"
    assert view |> element("input#ingredient_form_name") |> render() =~ ing.name

    assert view |> form("form#ingredient_form") |> render_submit(%{"ingredient" => %{"name" => "foobar"}}) =~ "foobar"

    assert ExDiet.Food.get_ingredient!(ing.id).name == "foobar"
  end

  @tag authenticated: true
  test "create ingredient", %{conn: conn, user: user} do
    {:ok, view, _html} = get(conn, Routes.ingredient_path(@endpoint, :index)) |> live()

    assert view
           |> form("form#ingredient_form")
           |> render_submit(%{
             "ingredient" => %{
               "carbonhydrate" => "1.1",
               "fat" => "1.2",
               "protein" => "1.3",
               "energy" => "42",
               "name" => "foobar"
             }
           }) =~ "foobar"

    assert [%{name: "foobar"}] = ExDiet.Repo.preload(user, :ingredients).ingredients
  end

  @tag authenticated: true
  test "ingredients filter", %{conn: conn, user: user} do
    filter = "b"
    names_match_filter = ["ingredient-abc", "ingredient-cdb", "ingredient-bxd"]
    names_dont_match_filter = ["ingredient-aaa", "ingredient-ddd", "ingredient-xxx"]

    for name <- names_match_filter ++ names_dont_match_filter do
      insert(:ingredient, name: name, user: user)
    end

    {:ok, view, html} = get(conn, Routes.ingredient_path(@endpoint, :index)) |> live()

    for name <- names_match_filter ++ names_dont_match_filter do
      assert html =~ name
    end

    html = view |> element("form#ingredients_filter") |> render_change(%{"q" => filter})

    for name <- names_match_filter do
      assert html =~ name
    end

    for name <- names_dont_match_filter do
      refute html =~ name
    end
  end
end
