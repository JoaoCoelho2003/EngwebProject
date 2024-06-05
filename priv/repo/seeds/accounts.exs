defmodule Engweb.Repo.Seeds.Accounts do

  alias Engweb.Accounts
  alias Engweb.Accounts.User
  alias Engweb.Repo

  @accounts File.read!("priv/fake/users.txt") |> String.split("\n")

  def run do
    case Repo.all(User) do
      [] ->
        seed_users(@accounts)

      _ ->
        Mix.shell().error("Found users, aborting seeding users.")
    end
  end

  def seed_users(characters) do

    case Accounts.register_user(%{
      email: "admin@mail.pt",
      password: "password1234",
      name: "admin",
      filiation: "docente",
      role: "admin"
    }) do
      {:ok, changeset} ->
        Repo.update!(Accounts.User.confirm_changeset(changeset))

      {:error, changeset} ->
        Mix.shell().error(Kernel.inspect(changeset.errors))
    end

    for character <- characters do
      email = (character |> String.downcase() |> String.replace(~r/\s*/, "")) <> "@mail.pt"

      user = %{
        "email" => email,
        "password" => "password1234",
        "name" => character,
        "filiation" => "student",
        "role" => "user"
      }

      case Accounts.register_user(user) do
        {:ok, changeset} ->
          Repo.update!(Accounts.User.confirm_changeset(changeset))

        {:error, changeset} ->
          Mix.shell().error(Kernel.inspect(changeset.errors))
      end
    end
  end
end

Engweb.Repo.Seeds.Accounts.run()
