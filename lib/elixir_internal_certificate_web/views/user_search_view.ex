defmodule ElixirInternalCertificateWeb.UserSearchView do
  use ElixirInternalCertificateWeb, :view

  def get_status(value) do
    cond do
      value == :pending -> "text-warning"
      value == :in_progress -> "text-info"
      value == :failed -> "text-danger"
      value == :success -> "text-success"
    end
  end

  def is_active_page?(_page, nil), do: nil

  def is_active_page?(page, target), do: if(page == target, do: "active", else: "")
end
