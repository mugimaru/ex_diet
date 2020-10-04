defmodule ExDietLiveWeb.Food.IngredientLive do
  @moduledoc false

  use ExDietLiveWeb, :live_view
  alias ExDiet.Food

  @impl true
  def mount(_params, session, socket) do
    :ok = Food.subscribe(Food.Ingredient)
    {:ok, assign_user(session, socket) |> set_form_changeset() |> assign(:data, [])}
  end

  @impl true
  def handle_info({Food, _, _ingredient}, socket) do
    {:noreply, assign(socket, :data, load_data(socket.assigns.current_user, socket.assigns.filter))}
  end

  @impl true
  def handle_event("select_item", %{"id" => id}, socket) do
    case Integer.parse(id) do
      {id, ""} ->
        case Enum.find(socket.assigns.data, &(&1.id == id)) do
          nil ->
            {:noreply, socket}

          ing ->
            {:noreply, set_form_changeset(socket, ing)}
        end

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("delete", _params, socket) do
    case socket.assigns.changeset.data do
      %{id: nil} ->
        {:noreply, socket}

      %Food.Ingredient{} = ing ->
        case Food.delete_ingredient(ing) do
          {:ok, _} ->
            {:noreply, set_form_changeset(socket)}

          {:error, :referenced} ->
            {:noreply,
             put_flash(socket, :error, "#{inspect(ing.name)} is referenced from recipes and can not be deleted")}

          {:error, _} ->
            {:noreply, put_flash(socket, :error, "Error deleting ingredient.")}
        end
    end
  end

  def handle_event("filter", %{"q" => filter}, socket) do
    case get_patched_path(socket.assigns.uri, q: filter) do
      {:ok, path} ->
        {:noreply, push_patch(socket, to: path, replace: true)}

      {:unchanged, _path} ->
        {:noreply, socket}
    end
  end

  def handle_event("save", %{"ingredient" => params}, socket) do
    result =
      if socket.assigns.changeset_update do
        Food.update_ingredient(socket.assigns.changeset.data, params)
      else
        Food.create_ingredient(params)
      end

    case result do
      {:ok, _ingredient} ->
        {:noreply, set_form_changeset(socket)}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("reset_form", _, socket) do
    {:noreply, set_form_changeset(socket)}
  end

  @impl true
  def handle_params(params, uri, socket) do
    filter = Map.get(params, "q")
    {:noreply, assign(socket, uri: uri, data: load_data(socket.assigns.current_user, filter), filter: filter)}
  end

  defp set_form_changeset(socket, ingredient \\ %Food.Ingredient{}) do
    assign(socket, changeset: Food.change_ingredient(ingredient), changeset_update: !!ingredient.id)
  end

  defp load_data(user, filter) do
    Food.Ingredient
    |> Food.Queries.Calendar.for_user(user)
    |> Food.Queries.Ingredient.search(%{filter: filter})
    |> Food.Queries.Ingredient.most_used_first()
    |> ExDiet.Repo.all()
  end
end
