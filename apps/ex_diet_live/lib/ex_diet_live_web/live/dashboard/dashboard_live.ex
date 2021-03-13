defmodule ExDietLiveWeb.DashboardLive do
  @moduledoc false

  use ExDietLiveWeb, :live_view
  alias ExDiet.Food

  @impl true
  def mount(_params, session, socket) do
    {:ok,
     assign_user(session, socket)
     |> assign(:hide_widgets_before_today, true)
     |> set_current_week()
     |> reload_data()}
  end

  @impl true
  def handle_event("set_current_week", _, socket) do
    {:noreply, set_current_week(socket) |> reload_data()}
  end

  def handle_event("set_prev_week", _, socket) do
    {:noreply, shift_interval(socket, -7) |> reload_data()}
  end

  def handle_event("set_next_week", _, socket) do
    {:noreply, shift_interval(socket, 7) |> reload_data()}
  end

  def handle_event("toggle_hide_widgets_before_today", _, socket) do
    {:noreply, assign(socket, :hide_widgets_before_today, !socket.assigns.hide_widgets_before_today)}
  end

  def handle_event("mark_as_eaten", %{"id" => id}, socket) do
    int_id = String.to_integer(id)

    case Enum.find(socket.assigns.recipes, fn %Food.Recipe{id: id} -> id == int_id end) do
      %Food.Recipe{eaten: false} = recipe ->
        case Food.update_recipe(recipe, %{eaten: true}) do
          {:ok, _} ->
            {:noreply, assign(socket, recipes: fetch_recipes(socket.assigns.current_user))}

          {:error, _reason} ->
            {:noreply, put_flash(socket, :error, "Error updating recipe")}
        end

      _ ->
        {:noreply, put_flash(socket, :error, "Recipe not found")}
    end
  end

  defp shift_interval(%{assigns: %{from_date: from, to_date: to}} = socket, value) do
    assign(socket, from_date: Date.add(from, value), to_date: Date.add(to, value))
  end

  defp set_current_week(socket) do
    now = Timex.now()
    from = now |> Timex.beginning_of_week() |> Timex.to_date()
    to = now |> Timex.end_of_week() |> Timex.to_date()

    assign(socket, from_date: from, to_date: to)
  end

  defp reload_data(%{assigns: %{from_date: from_date, to_date: to_date, current_user: user}} = socket) do
    calendar = fetch_calendar(user, from_date, to_date)

    assign(socket,
      calendar: calendar,
      recipes: fetch_recipes(user) |> add_eaten_recipes_from_calendar(calendar)
    )
  end

  defp add_eaten_recipes_from_calendar(recipes, calendars) do
    recipes_map = Enum.into(recipes, %{}, &{&1.id, &1})

    Enum.reduce(calendars, recipes_map, fn %Food.Calendar{} = c, recipes_map ->
      Enum.reduce(c.meals, recipes_map, fn meal, recipes_map ->
        if meal.recipe && is_nil(recipes_map[meal.recipe.id]) do
          Map.put(recipes_map, meal.recipe.id, meal.recipe)
        else
          recipes_map
        end
      end)
    end)
    |> Map.values()
    |> Enum.sort_by(&{&1.eaten, &1.name})
  end

  defp fetch_recipes(user) do
    Food.Recipe
    |> Food.Queries.Calendar.for_user(user)
    |> Food.Queries.Recipe.search(%{eaten: false})
    |> Food.Queries.Recipe.preload_ingredients()
    |> ExDiet.Repo.all()
  end

  defp fetch_calendar(user, from_date, to_date) do
    cals =
      Food.Calendar
      |> Food.Queries.Calendar.for_user(user)
      |> Food.Queries.Calendar.filter(%{before: to_date, after: from_date})
      |> Food.Queries.Calendar.preload_meals()
      |> ExDiet.Repo.all()

    Enum.reduce(dates_range(from_date, to_date, []), cals, fn day, cals ->
      if Enum.any?(cals, &(&1.day == day)) do
        cals
      else
        empty_calendar = ExDiet.Food.Calendar.__struct__(day: day, user_id: user.id, user: user, meals: [])

        [empty_calendar | cals]
      end
    end)
    |> Enum.sort_by(& &1.day, :asc)
  end

  defp dates_range(to, to, acc) do
    Enum.reverse(acc)
  end

  defp dates_range(from, to, acc) do
    dates_range(Date.add(from, 1), to, [from | acc])
  end
end
