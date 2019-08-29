# UnionType

Define union types in Elixir!

## Example

```elixir
defmodule UserEnum do
  use UnionType

  union_type do
    customer(name)
    admin(name)
    contractor(name, company)
    guest()
  end
end

defmodule App do
  require UserEnum

  def greet(UserEnum.guest()) do
    "howdy guest!"
  end

  def greet(UserEnum.customer(name)) do
    "howdy #{name}!"
  end
  
  def greet(UserEnum.admin(name)) do
    "howdy #{name}! You are an admin!"
  end

  def greet(UserEnum.contractor(name, company)) do
    "howdy #{name}! You are a contractor for #{company}"
  end
end

iex(18)> require UserEnum
UserEnum

iex(20)> App.greet(UserEnum.guest())
"howdy guest!"

iex(21)> App.greet(UserEnum.customer("John"))
"howdy John!"

iex(22)> App.greet(UserEnum.admin("Linda"))
"howdy Linda! You are an admin!"

iex(23)> App.greet(UserEnum.contractor("Erin", "MainTech"))
"howdy Erin! You are a contractor for MainTech"
```


