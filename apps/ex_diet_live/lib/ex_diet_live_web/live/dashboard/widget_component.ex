defmodule ExDietLiveWeb.Dashboard.WidgetComponent do
  @moduledoc false

  use ExDietLiveWeb, :live_component
  alias ExDiet.Food

  def update(assigns, socket) do
    {:ok, assign(socket, calendar: assigns.calendar, totals: Food.NutritionFacts.calculate(assigns.calendar))}
  end
end
