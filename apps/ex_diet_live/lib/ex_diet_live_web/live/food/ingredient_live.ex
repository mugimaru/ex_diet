defmodule ExDietLiveWeb.Food.IngredientLive do
  @moduledoc false

  use ExDietLiveWeb, :live_view
  alias ExDiet.Food

  @impl true
  def mount(_params, session, socket) do
    :ok = Food.subscribe(Food.Ingredient)

    socket =
      assign_user(session, socket)
      |> set_form_changeset()
      |> assign(has_next_page: false, page: 1, update_mode: :append)

    {:ok, socket, temporary_assigns: [data: []]}
  end

  @impl true
  def handle_params(params, uri, %{assigns: %{current_user: user}} = socket) do
    filter = Map.get(params, "q")
    page = 1
    {has_next_page, new_data} = load_page(user, filter, page)

    {:noreply,
     assign(socket,
       uri: uri,
       data: new_data,
       has_next_page: has_next_page,
       filter: filter,
       page: page,
       update_mode: :replace
     )}
  end

  @impl true
  def handle_info({Food, :delete, ingredient}, %{assigns: %{current_user: user, filter: filter, page: page}} = socket) do
    if ingredient.user_id == user.id do
      {:noreply, assign(socket, data: reload_data(user, filter, page), update_mode: :replace)}
    else
      {:noreply, socket}
    end
  end

  def handle_info({Food, _event, ingredient}, %{assigns: %{current_user: user, filter: filter}} = socket) do
    if is_nil(filter) || (user.id == ingredient.user_id && String.contains?(ingredient.name, filter)) do
      {:noreply, assign(socket, data: [ingredient], update_mode: :append)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("select_item", %{"id" => id}, socket) do
    {:noreply, set_form_changeset(socket, Food.get_ingredient!(id))}
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
      {:ok, ingredient} ->
        {:noreply, socket |> set_form_changeset() |> assign(data: [ingredient], update_mode: :append)}

      {:error, changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def handle_event("reset_form", _, socket) do
    {:noreply, set_form_changeset(socket)}
  end

  def handle_event("load_more", _params, %{assigns: %{current_user: user, page: page, filter: filter}} = socket) do
    {has_next_page, new_data} = load_page(user, filter, page + 1)
    {:noreply, assign(socket, data: new_data, has_next_page: has_next_page, page: page + 1, update_mode: :append)}
  end

  defp set_form_changeset(socket, ingredient \\ %Food.Ingredient{}) do
    assign(socket, changeset: Food.change_ingredient(ingredient), changeset_update: !!ingredient.id)
  end

  @per_page 30
  defp reload_data(user, filter, page) do
    do_load_data(user, filter, page * @per_page, 0)
  end

  defp load_page(user, filter, page) do
    offset = (page - 1) * @per_page
    data = do_load_data(user, filter, @per_page, offset)

    {Enum.count(data) == @per_page, data}
  end

  defp do_load_data(user, filter, limit, offset) do
    Food.Ingredient
    |> Food.Queries.Calendar.for_user(user)
    |> Food.Queries.Ingredient.search(%{filter: filter})
    |> Food.Queries.Ingredient.most_used_first()
    |> Food.Queries.Ingredient.slice(limit, offset)
    |> ExDiet.Repo.all()
  end
end
