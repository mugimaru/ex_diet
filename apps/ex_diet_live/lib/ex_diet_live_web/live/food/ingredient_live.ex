defmodule ExDietLiveWeb.Food.IngredientLive do
  @moduledoc false

  use ExDietLiveWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    {:ok, assign_user(session, socket)}
  end
end
