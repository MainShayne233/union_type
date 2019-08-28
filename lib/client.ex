defmodule ClientEnum do
  use TypedTuple

  deftuple do
    user(name)
    guest()
  end
end

defmodule Client do
  require ClientEnum

  def greet(ClientEnum.guest()) do
    IO.puts "howdy guest!"
  end

#  def greet(ClientEnum.match__user(name)) do
#    IO.puts "howdy user"
#  end
end

