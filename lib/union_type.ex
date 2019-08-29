defmodule UnionType do
  @enforce_keys [:module, :name, :values]

  defstruct @enforce_keys

  defimpl Inspect, for: __MODULE__ do
    def inspect(union_type, _opts) do
      module =
        union_type.module
        |> Module.split()
        |> Enum.join(".")

      args =
        union_type.values
        |> Tuple.to_list()
        |> Enum.map_join(", ", &inspect/1)

      "#{module}.#{union_type.name}(#{args})"
    end
  end

  defmacro __using__(_options) do
    quote do
      import UnionType, only: [union_type: 1]
    end
  end

  defmacro union_type(do: {:__block__, _, variants}) do
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
    quote do
      defmacro unquote(name)(unquote_splicing(args)) do
        is_match_expression? =
          Enum.all?(binding(), fn
            {name, {value, _, nil}} when is_atom(name) and is_atom(value) ->
              true

            _other ->
              false
          end)

        match_vars = Enum.map(binding(), &elem(&1, 1))

        if is_match_expression? do
          name = unquote(name)
          caller = unquote(caller)

          quote do
            %UnionType{
              module: unquote(caller),
              name: unquote(name),
              values: {unquote_splicing(match_vars)}
            }
          end
        else
          Macro.escape(%UnionType{
            module: unquote(caller),
            name: unquote(name),
            values: List.to_tuple(match_vars)
          })
        end
      end
    end
  end
end
