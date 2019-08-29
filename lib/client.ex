defmodule ClientEnum do
  use TypedTuple

  deftuple do
    admin(name, role)
    user(name)
    criminal(crime)
    guest()
  end
end

defmodule Client do
  require ClientEnum

  def greet(ClientEnum.guest()) do
    IO.puts("howdy guest!")
  end

  def greet(ClientEnum.user(name)) do
    IO.puts("howdy #{name}!")
  end

  def greet(ClientEnum.criminal(crime)) do
    IO.puts("You commited: #{crime}. Get out of here!")
  end

  def greet(ClientEnum.admin(name, role)) do
    IO.puts("howdy #{name}! you are a #{role}")
  end

  #  def greet(ClientEnum.match__user(name)) do
  #    IO.puts "howdy user"
  #  end
end

# defmodule MatchMacro do
#   defmacro match(arg, other_arg) do
#     IO.inspect({arg, other_arg})
#     quote do
#       unquote_splicing([{{:x, [], nil}, {:_, [], nil}}])
#     end
#   end
# end
# 
# quote do
#   defmodule User do
#     require MatchMacro
#     defstruct [:name, :age]
# 
#     def is_john?(MatchMacro.match(arg, _)) do
#       x
#     end
#   end
# end
# |> Macro.to_string()
# |> (fn x -> IO.puts(x); x end).()
# |> Code.compile_string()
