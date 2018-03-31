defmodule ExDiet.Factory do
  @moduledoc false

  use ExMachina.Ecto, repo: ExDiet.Repo

  def ingredient_factory do
    %ExDiet.Food.Ingredient{
      name: sequence("ingredient"),
      protein: Enum.random(1..100) * 0.31,
      fat: Enum.random(1..100) * 0.31,
      carbonhydrate: Enum.random(1..100) * 0.31,
      energy: Enum.random(100..500) * 0.31,
      user: build(:user)
    }
  end

  def user_factory do
    %ExDiet.Accounts.User{
      email: sequence(:email, &"user-#{&1}@example.com"),
      password_hash: sequence("Password")
    }
  end
end
