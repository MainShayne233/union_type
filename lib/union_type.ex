defmodule UnionType do
  @type t :: %__MODULE__{
          __module__: module(),
          __name__: atom(),
          __values__: tuple()
        }

  @enforce_keys [:__module__, :__name__, :__values__]

  defstruct @enforce_keys

  defmacro __using__(_options) do
    quote do
      import UnionType, only: [union_type: 1]
    end
  end

  @doc """
  Provides a mechanism for defining a union type.

  ## Example

      iex> defmodule AuthEnum do
      ...>   use UnionType
      ...>
      ...>   union_type do
      ...>     admin(level)
      ...>     none()
      ...>   end
      ...> end
      ...>
      ...> defmodule App do
      ...>   require AuthEnum
      ...>
      ...>   def grant_access?(AuthEnum.admin(level)) do
      ...>     level == :top
      ...>   end
      ...>
      ...>   def grant_access?(AuthEnum.none()) do
      ...>     false
      ...>   end
      ...>
      ...>   def check, do: grant_access?(AuthEnum.admin(:top))
      ...> end
      ...>
      ...> App.check()
      true
  """
  defmacro union_type(do: {:__block__, _, variants}) do
    Enum.map(variants, &generate_variant(&1, __CALLER__.module))
  end

  @doc """
  Serializes the union type value into a plain Elixir tuple.

  ## Examples

      iex> UserEnum.customer(\"John\") |> UnionType.to_tuple()
      {UserEnum, :customer, {\"John\"}}

      iex> UserEnum.admin(\"Linda\") |> UnionType.to_tuple()
      {UserEnum, :admin, {\"Linda\"}}

      iex> UserEnum.contractor(\"Erin\", \"TechCo\") |> UnionType.to_tuple()
      {UserEnum, :contractor, {\"Erin\", \"TechCo\"}}

      iex> UserEnum.guest() |> UnionType.to_tuple()
      {UserEnum, :guest, {}}
  """
  @spec to_tuple(t()) :: {module(), variant_name :: atom(), tuple()}
  def to_tuple(%__MODULE__{__module__: module, __name__: name, __values__: values}) do
    {module, name, values}
  end

  @doc """
  Deserializes the Elixir tuple into a union type.

  ## Examples

      iex> UnionType.from_tuple({UserEnum, :customer, {\"John\"}})
      UserEnum.customer(\"John\")

      iex> UnionType.from_tuple({UserEnum, :admin, {\"Linda\"}})
      UserEnum.admin(\"Linda\")

      iex> UnionType.from_tuple({UserEnum, :contractor, {\"Erin\", \"TechCo\"}})
      UserEnum.contractor(\"Erin\", \"TechCo\")

      iex> UnionType.from_tuple({UserEnum, :guest, {}})
      UserEnum.guest()
  """
  @spec from_tuple({module(), variant_name :: atom(), tuple()}) :: t()
  def from_tuple({module, name, values}) do
    %__MODULE__{__module__: module, __name__: name, __values__: values}
  end

  @doc """
  Like Kernel.elem/2, but operates on the values of the union type.

  ## Examples

      iex> UserEnum.customer(\"John\") |> UnionType.at(0)
      \"John\"

      iex> UserEnum.contractor(\"Erin\", \"TechCo\") |> UnionType.at(1)
      \"TechCo\"
  """
  @spec at(t(), non_neg_integer()) :: term()
  def at(%__MODULE__{__values__: values}, index) do
    elem(values, index)
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

        match_vars = binding() |> Enum.map(&elem(&1, 1)) |> Enum.reverse()

        if is_match_expression? do
          name = unquote(name)
          caller = unquote(caller)

          quote do
            %UnionType{
              __module__: unquote(caller),
              __name__: unquote(name),
              __values__: {unquote_splicing(match_vars)}
            }
          end
        else
          Macro.escape(%UnionType{
            __module__: unquote(caller),
            __name__: unquote(name),
            __values__: List.to_tuple(match_vars)
          })
        end
      end
    end
  end

  defimpl String.Chars do
    def to_string(union_type) do
      module =
        union_type.__module__
        |> Module.split()
        |> Enum.join(".")

      args =
        union_type.__values__
        |> Tuple.to_list()
        |> Enum.map_join(", ", &inspect/1)

      "#{module}.#{union_type.__name__}(#{args})"
    end
  end

  defimpl Inspect do
    def inspect(union_type, _opts) do
      to_string(union_type)
    end
  end
end
