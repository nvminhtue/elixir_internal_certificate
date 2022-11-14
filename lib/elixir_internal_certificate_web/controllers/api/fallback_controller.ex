defmodule ElixirInternalCertificateWeb.Api.FallbackController do
  use Phoenix.Controller

  alias Ecto.Changeset
  alias ElixirInternalCertificateWeb.Api.ErrorView

  def call(conn, {:error, %Changeset{valid?: false} = changeset}) do
    conn
    |> put_status(:unprocessable_entity)
    |> put_view(ErrorView)
    |> render("error.json", %{code: :unprocessable_entity, changeset: changeset})
  end
end
