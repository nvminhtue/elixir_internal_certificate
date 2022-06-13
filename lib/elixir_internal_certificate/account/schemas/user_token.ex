defmodule ElixirInternalCertificate.Account.Schemas.UserToken do
  use Ecto.Schema

  alias ElixirInternalCertificate.Account.Queries.UserTokenQuery
  alias ElixirInternalCertificate.Account.Schemas.UserToken

  @rand_size 32

  # It is very important to keep the reset password token expiry short,
  # since someone with access to the email may take over the account.

  schema "users_tokens" do
    field :token, :binary
    field :context, :string
    belongs_to :user, ElixirInternalCertificate.Account.Schemas.User

    timestamps(updated_at: false)
  end

  @doc """
  Generates a token that will be stored in a signed place,
  such as session or cookie. As they are signed, those
  tokens do not need to be hashed.

  The reason why we store session tokens in the database, even
  though Phoenix already provides a session cookie, is because
  Phoenix' default session cookies are not persisted, they are
  simply signed and potentially encrypted. This means they are
  valid indefinitely, unless you change the signing/encryption
  salt.

  Therefore, storing them allows individual user
  sessions to be expired. The token system can also be extended
  to store additional data, such as the device used for logging in.
  You could then use this information to display all valid sessions
  and devices in the UI and allow users to explicitly expire any
  session they deem invalid.
  """
  def build_session_token(user) do
    token = :crypto.strong_rand_bytes(@rand_size)
    {token, %UserToken{token: token, context: "session", user_id: user.id}}
  end

  @doc """
  Checks if the token is valid and returns its underlying lookup query.

  The query returns the user found by the token, if any.

  The token is valid if it matches the value in the database and it has
  not expired (after @session_validity_in_days).
  """
  def verify_session_token_query(token) do
    query = UserTokenQuery.session_token_query(token)

    {:ok, query}
  end
end
