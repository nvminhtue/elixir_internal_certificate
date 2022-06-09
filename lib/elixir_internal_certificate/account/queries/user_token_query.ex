defmodule ElixirInternalCertificate.Account.Queries.UserTokenQuery do
  import Ecto.Query

  alias ElixirInternalCertificate.Account.Schemas.UserToken

  @session_validity_in_days 60

  def session_token_query(token) do
    from token in token_and_context_query(token, "session"),
      join: user in assoc(token, :user),
      where: token.inserted_at > ago(@session_validity_in_days, "day"),
      select: user
  end

  @doc """
  Returns the token struct for the given token value and context.
  """
  def token_and_context_query(token, context),
    do: where(UserToken, token: ^token, context: ^context)
end
