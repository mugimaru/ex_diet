defmodule ExDietLiveWeb.LiveViewHelpers do
  @moduledoc false
  import Phoenix.LiveView

  def assign_user(%{"user_id" => user_id}, socket) do
    assign_new(socket, :current_user, fn -> ExDiet.Accounts.get_user!(user_id) end)
  end

  @spec get_patched_path(uri :: String.t(), params_to_add :: Enumerable.t()) ::
          {:ok | :unchanged, new_path :: String.t()}
  @doc """
  Merges given params into query string and returns resulting path and query string
  wich might be useful to update query string via `Phoenix.LiveView.push_patch/2`.
  """
  def get_patched_path(uri, params) do
    uri = URI.parse(uri)
    params = Enum.into(params, %{}, fn {k, v} -> {to_string(k), v} end)

    query_params = URI.decode_query(uri.query || "")

    changed_params =
      Enum.reduce(Map.merge(query_params, params), %{}, fn {k, v}, acc ->
        if is_nil(v) || v == "" do
          acc
        else
          Map.put(acc, k, v)
        end
      end)

    path = uri.path <> "?" <> URI.encode_query(changed_params)

    if query_params == changed_params do
      {:unchanged, path}
    else
      {:ok, path}
    end
  end

  def format_number(num), do: format_number(num, [])

  def format_number(%Decimal{} = num, opts) do
    precision = Keyword.get(opts, :precision, 2)

    if precision == 0 do
      num |> Decimal.round() |> Decimal.to_integer() |> to_string()
    else
      case num |> Decimal.round(precision) |> to_string() |> String.split(".") do
        [num] ->
          num <> "." <> repeat_str("0", precision)

        [num, fr] ->
          num <> "." <> String.pad_leading(fr, precision, "0")
      end
    end
  end

  def format_number(num, _opts) when is_integer(num) do
    to_string(num)
  end

  def format_number(num, opts) when is_number(num) do
    num |> Decimal.from_float() |> format_number(opts)
  end

  defp repeat_str(str, times) do
    Enum.reduce(1..times, "", fn _, acc -> acc <> str end)
  end
end
