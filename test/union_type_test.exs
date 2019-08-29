defmodule UserEnum do
  use UnionType

  union_type do
    customer(name)
    admin(name)
    contractor(name, company)
    guest()
  end
end

defmodule UnionTypeTest do
  use ExUnit.Case

  require UserEnum
  doctest UnionType

  test "should produce the correct internal struct" do
    assert UserEnum.customer("John") == %UnionType{
             __module__: UserEnum,
             __name__: :customer,
             __values__: {"John"}
           }

    assert UserEnum.admin("Linda") == %UnionType{
             __module__: UserEnum,
             __name__: :admin,
             __values__: {"Linda"}
           }

    assert UserEnum.contractor("Erin", "TechCo") == %UnionType{
             __module__: UserEnum,
             __name__: :contractor,
             __values__: {"Erin", "TechCo"}
           }

    assert UserEnum.guest() == %UnionType{
             __module__: UserEnum,
             __name__: :guest,
             __values__: {}
           }
  end

  test "to_string/1 and inspect/2 should produce opaque type values" do
    customer = UserEnum.customer("John")
    admin = UserEnum.admin("Linda")
    contractor = UserEnum.contractor("Erin", "TechCo")
    guest = UserEnum.guest()

    assert Enum.all?(
             [to_string(customer), inspect(customer)],
             &(&1 == "UserEnum.customer(\"John\")")
           )

    assert Enum.all?([to_string(admin), inspect(admin)], &(&1 == "UserEnum.admin(\"Linda\")"))

    assert Enum.all?(
             [to_string(contractor), inspect(contractor)],
             &(&1 == "UserEnum.contractor(\"Erin\", \"TechCo\")")
           )

    assert Enum.all?([to_string(guest), inspect(guest)], &(&1 == "UserEnum.guest()"))
  end
end
