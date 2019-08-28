defmodule TypedTuple do
  @enforce_keys [:module, :name, :values]

  defstruct @enforce_keys

  # defimpl Inspect, for: __MODULE__ do
  #   def inspect(typed_tuple, _opts) do
  #     module =
  #       typed_tuple.module
  #       |> Module.split()
  #       |> Enum.join(".")

  #     args =
  #       typed_tuple.values
  #       |> Tuple.to_list()
  #       |> Enum.map_join(", ", &inspect/1)

  #     "#{module}.#{typed_tuple.name}(#{args})"
  #   end
  # end

  defmacro __using__(_options) do
    quote do
      import TypedTuple, only: [deftuple: 1]
    end
  end

  defmacro deftuple(do: {:__block__, _, variants}) do
    Enum.map(variants, &generate_variant(&1, __CALLER__.module))
  end

  defp generate_variant(variant, caller) do
    quote do
      unquote(generate_doc())
      unquote(generate_function(variant, caller))
    end
  end

  defp generate_doc do
    quote do
      @doc """
      TODO: Make this useful
      """
    end
  end

  defp generate_function({name, _, args}, caller) do
    params = generate_params(args)
    match_vars = generate_match_vars(args)

    quote do
      defmacro unquote(name)(unquote_splicing(params)) do
        Macro.escape({unquote(name), unquote_splicing(params)})
        # Macro.escape(%TypedTuple{
        #   module: unquote(caller),
        #   name: unquote(name),
        #   values: {unquote_splicing(params)}
        # })
      end

      defmacro unquote(:"match__#{name}")(arg1) do
        {:value, arg1}
        # Macro.escape(%TypedTuple{
        #   module: unquote(caller),
        #   name: unquote(name),
        #   values: {unquote_splicing(params)}
        # })
      end
    end
  end

  defp generate_match_vars(params) do
    Enum.map(params, fn {name, _, _} ->
      {name, [], Elixir}
    end)
  end

  defp generate_params(params) do
    Enum.map(params, fn {name, _, _} ->
      quote do
        unquote(name)
      end
    end)
  end
end
