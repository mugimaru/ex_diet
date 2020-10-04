defmodule ExDietLiveWeb.PhoenixHTMLBootstrapHelpers do
  @moduledoc false

  alias ExDietLiveWeb.Router.Helpers, as: Routes
  alias Phoenix.HTML.{Tag, Form}

  def icon(name, opts \\ []) do
    classes = Keyword.get(opts, :class, "") |> String.split(" ")
    class = Enum.uniq(["bi" | classes]) |> Enum.filter(&(&1 != "")) |> Enum.join(" ")

    opts =
      opts
      |> Keyword.put(:class, class)
      |> Keyword.put(:width, "1em")
      |> Keyword.put(:height, "1em")

    Tag.content_tag :svg, opts do
      Tag.content_tag(:use, nil,
        "xlink:href": Routes.static_path(ExDietLiveWeb.Endpoint, "/images/bootstrap-icons.svg##{name}")
      )
    end
  end

  def bs_text_input(form, field, opts \\ []) do
    Form.text_input(form, field, validation_mutate_class_opts(form, field, opts))
  end

  def bs_number_input(form, field, opts \\ []) do
    Form.number_input(form, field, validation_mutate_class_opts(form, field, opts))
  end

  defp validation_mutate_class_opts(form, field, opts) do
    class = Keyword.get(opts, :class)
    is_invalid = if Enum.any?(Keyword.get_values(form.errors, field)), do: "is-invalid", else: ""

    Keyword.put(opts, :class, Enum.join([class, is_invalid], " "))
  end
end
