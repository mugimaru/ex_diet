defmodule ExDiet.Schema do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      use Ecto.Schema

      @timestamps_opts [type: :utc_datetime, usec: true]
    end
  end
end
