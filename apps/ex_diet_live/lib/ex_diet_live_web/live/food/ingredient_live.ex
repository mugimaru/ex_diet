defmodule ExDietLiveWeb.Food.IngredientLive do
  @moduledoc false

  use ExDietLiveWeb, :live_view
  alias ExDiet.Food

  @impl true
  def mount(params, session, socket) do
    socket = assign_user(session, socket)
    {:ok, assign(socket, data: [], changeset: Food.change_ingredient(%Food.Ingredient{}))}
  end

  def handle_event("filter", %{"q" => filter}, socket) do
    case get_patched_path(socket.assigns.uri, q: filter) do
      {:ok, path} ->
        {:noreply, push_patch(socket, to: path, replace: true)}
      {:unchanged, path} ->
        {:noreply, socket}
    end
  end

  def handle_event("validate", %{"ingredient" => params}, socket) do
    changeset =
      %Food.Ingredient{}
      |> Food.change_ingredient(params)
      |> Map.put(:action, :insert)

    {:noreply, assign(socket, changeset: changeset)}
  end

  def handle_event("save", %{"ingredient" => params}, socket) do
    case Food.create_ingredient(params) do
      {:ok, ingredient} ->
        {:noreply, put_flash(socket, :info, "ok")}
      {:error, changeset} ->
        {:noreply, put_flash(assign(socket, changeset: changeset), :error, "nok")}
    end
  end

  def handle_params(params, uri, socket) do
    filter = Map.get(params, "q")
    {:noreply, assign(socket, uri: uri, data: load_data(socket.assigns.current_user, filter), filter: filter)}
  end

  defp load_data(user, filter) do
    Food.Ingredient
    |> Food.Queries.Calendar.for_user(user)
    |> Food.Queries.Ingredient.search(%{filter: filter})
    |> Food.Queries.Ingredient.most_used_first()
    |> ExDiet.Repo.all()
  end
end
