defmodule ExDietLiveWeb.Food.RecipeLive do
  @moduledoc false

  use ExDietLiveWeb, :live_view
  alias ExDiet.Food

  @impl true
  def mount(_params, session, socket) do
    socket = assign_user(session, socket)
    :ok = ExDietLive.Food.UserPubSubDispatcher.subscribe(socket.assigns.current_user, Food.Recipe)

    {:ok,
     assign(socket, has_next_page: false, page: 1, filter: %{filter: ""}, update_mode: :append),
     temporary_assigns: [data: []]}
  end

  @impl true
  def handle_params(params, uri, %{assigns: %{current_user: user}} = socket) do
    filter = Map.put(socket.assigns.filter, :filter, Map.get(params, "q"))
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
  def handle_info(
        {Food, :delete, _ingredient},
        %{assigns: %{current_user: user, filter: filter, page: page}} = socket
      ) do
    {:noreply, assign(socket, data: reload_data(user, filter, page), update_mode: :replace)}
  end

  def handle_info({Food, _event, ingredient}, %{assigns: %{filter: filter}} = socket) do
    if is_nil(filter) ||
         String.contains?(String.downcase(ingredient.name), String.downcase(filter)) do
      {:noreply, assign(socket, data: [ingredient], update_mode: :append)}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("select_item", %{"id" => _id}, socket) do
    # TODO: push redirect to recipe page
    {:noreply, socket}
  end

  def handle_event("filter", %{"q" => filter}, socket) do
    case get_patched_path(socket.assigns.uri, q: filter) do
      {:ok, path} ->
        {:noreply, push_patch(socket, to: path, replace: true)}

      {:unchanged, _path} ->
        {:noreply, socket}
    end
  end

  def handle_event("toggle_eaten_filter", _, %{assigns: %{filter: filter}} = socket) do
    new_filter =
      if is_nil(filter[:eaten]) do
        Map.put(filter, :eaten, false)
      else
        Map.delete(filter, :eaten)
      end

    {:noreply,
     assign(socket,
       filter: new_filter,
       data: reload_data(socket.assigns.current_user, new_filter, socket.assigns.page),
       update_mode: :replace
     )}
  end

  def handle_event(
        "load_more",
        _params,
        %{assigns: %{current_user: user, page: page, filter: filter}} = socket
      ) do
    {has_next_page, new_data} = load_page(user, filter, page + 1)

    {:noreply,
     assign(socket,
       data: new_data,
       has_next_page: has_next_page,
       page: page + 1,
       update_mode: :append
     )}
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
    Food.Recipe
    |> Food.Queries.Calendar.for_user(user)
    |> Food.Queries.Recipe.search(filter)
    |> Food.Queries.Recipe.preload_ingredients()
    |> Food.Queries.Ingredient.recent_first()
    |> Food.Queries.Ingredient.slice(limit, offset)
    |> ExDiet.Repo.all()
  end
end
