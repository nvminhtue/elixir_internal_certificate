defmodule ElixirInternalCertificate.Account.AccountsTest do
  use ElixirInternalCertificate.DataCase, async: true

  alias ElixirInternalCertificate.Account.Accounts
  alias ElixirInternalCertificate.Account.Schemas.{User, UserToken}

  describe "get_user_by_email/1" do
    test "with the existed email, returns the user" do
      %{id: id} = insert(:user, email: "random_email@mail.com")

      assert %User{id: ^id} = Accounts.get_user_by_email("random_email@mail.com")
    end

    test "when the email does not exist, return nil" do
      assert Accounts.get_user_by_email("unknown@example.com") == nil
    end
  end

  describe "get_user_by_email_and_password/2" do
    test "when the email and password are valid, returns the user" do
      %{id: id, email: email} = insert(:user)

      assert %User{id: ^id} = Accounts.get_user_by_email_and_password(email, valid_user_password())
    end

    test "when the email does not exist, return nil" do
      assert Accounts.get_user_by_email_and_password("unknown@example.com", "hello world!") == nil
    end

    test "when the password is not valid, return nil" do
      user = insert(:user)
      assert Accounts.get_user_by_email_and_password(user.email, "invalid") == nil
    end
  end

  describe "get_user!/1" do
    test "with the given id, returns the user" do
      %{id: id} = insert(:user)

      assert %User{id: ^id} = Accounts.get_user!(id)
    end

    test "when id is invalid, raises a no result error" do
      assert_raise Ecto.NoResultsError, fn ->
        Accounts.get_user!(-1)
      end
    end
  end

  describe "register_user/1" do
    test "when email is unique and password is valid, email is stored, password is cleared and hashed_password is created" do
      email = unique_user_email()

      {:ok, user} = Accounts.register_user(valid_user_attributes(email: email))

      assert user.email == email
      assert is_binary(user.hashed_password)
      assert is_nil(user.password)
    end

    test "when email and password are blank, requires validation error will be throw" do
      {:error, changeset} = Accounts.register_user(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "when email and password are not valid, requires validation error will be throw" do
      {:error, changeset} = Accounts.register_user(%{email: "not valid", password: "short"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 6 character(s)"]
             } = errors_on(changeset)
    end

    test "when email and password are too long, requires validation error will be throw" do
      too_long = String.duplicate("db", 100)

      {:error, changeset} = Accounts.register_user(%{email: too_long, password: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "when email is already existed, requires validation error will be throw" do
      %{email: email} = insert(:user)

      {:error, changeset} = Accounts.register_user(%{email: email})

      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, upcase_changeset} = Accounts.register_user(%{email: String.upcase(email)})

      assert "has already been taken" in errors_on(upcase_changeset).email
    end
  end

  describe "change_user_registration/2" do
    test "when jump to the route of registration, returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Accounts.change_user_registration(%User{})
      assert changeset.required == [:password, :email]
    end

    test "when changset is created, allows fields to be set" do
      email = unique_user_email()
      password = valid_user_password()

      changeset =
        Accounts.change_user_registration(
          %User{},
          valid_user_attributes(email: email, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "generate_user_session_token/1" do
    test "when generate_user_session_token/1 is call, generates a token" do
      # token = Accounts.generate_user_session_token(user)
      %{token: token} = user_token_record = insert(:user_token)

      assert user_token = Repo.get_by(UserToken, token: token)
      assert user_token.context == "session"

      # Creating the same token for another user should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%UserToken{
          token: user_token.token,
          user_id: user_token_record.user.id,
          context: "session"
        })
      end
    end
  end

  describe "get_user_by_session_token/1" do
    test "when called, returns user by token" do
      user_token = insert(:user_token)

      assert session_user = Accounts.get_user_by_session_token(user_token.token)
      assert session_user.id == user_token.user.id
    end

    test "when using invalid token, returns nil" do
      assert Accounts.get_user_by_session_token("oops") == nil
    end

    test "when using expired token, returns nil" do
      user_token = insert(:user_token)

      {1, nil} = Repo.update_all(UserToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])

      assert Accounts.get_user_by_session_token(user_token.token) == nil
    end
  end

  describe "delete_session_token/1" do
    test "when being called, deletes the token" do
      user = insert(:user)

      token = Accounts.generate_user_session_token(user)

      assert Accounts.delete_session_token(token) == :ok
      assert Accounts.get_user_by_session_token(token) == nil
    end
  end

  describe "inspect/2" do
    test "when user is created, does not include password" do
      assert inspect(%User{password: "123456"}) =~ "password: \"123456\"" == false
    end
  end
end
