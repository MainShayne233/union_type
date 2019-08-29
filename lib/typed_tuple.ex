defmodule TypedTuple do
  @keys [:module, :name, :values]

  defstruct @keys

  defimpl Inspect, for: __MODULE__ do
    def inspect(typed_tuple, _opts) do
      module =
        typed_tuple.module
        |> Module.split()
        |> Enum.join(".")

      args =
        typed_tuple.values
        |> Tuple.to_list()
        |> Enum.map_join(", ", &inspect/1)

      "#{module}.#{typed_tuple.name}(#{args})"
    end
  end

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

  defp generate_function({name, _, args} = ast, caller) do
    quote do
      defmacro unquote(name)(unquote_splicing(args)) do
        IO.inspect(binding())
        Macro.escape(%TypedTuple{
          module: unquote(caller),
          name: unquote(name),
          values: binding() |> Enum.map(&elem(&1, 1)) |> List.to_tuple()
        })
      end

      unquote(generate_match_function(ast, caller))
    end
  end

  defp generate_match_function({name, _, args}, caller) do
    macro_name = String.to_atom("match_#{name}")

    quote do
      defmacro unquote(macro_name)(unquote_splicing(args)) do
        match_vars = Enum.map(binding(), &elem(&1, 1))
        name = unquote(name)
        caller = unquote(caller)

        quote do
          %TypedTuple{module: unquote(caller), name: unquote(name), values: {unquote_splicing(match_vars)}}
        end
      end
    end
  end

  defp generate_params(params) do
    Enum.map(params, fn {name, _, _} ->
      quote do
        unquote(name)
      end
    end)
  end
end
