defmodule ExDietLiveWeb.LiveViewHelpers do
  @moduledoc false
  import Phoenix.LiveView

  def assign_user(%{"user_id" => user_id}, socket) do
    assign_new(socket, :current_user, fn -> ExDiet.Accounts.get_user!(user_id) end)
  end
end
