defmodule ElixirInternalCertificateWeb.Api.ErrorViewTest do
  use ElixirInternalCertificateWeb.ConnCase, async: true

  alias ElixirInternalCertificateWeb.Api.ErrorView

  defmodule Device do
    use Ecto.Schema

    import Ecto.Changeset

    schema "devices" do
      field :device_id, :string
      field :operating_system, :string
      field :device_name, :string

      timestamps()
    end

    def changeset(device \\ %__MODULE__{}, attrs) do
      device
      |> cast(attrs, [
        :device_id,
        :operating_system,
        :device_name
      ])
      |> validate_required([
        :device_id,
        :operating_system,
        :device_name
      ])
    end

    def custom_error_changeset(device \\ %__MODULE__{}, attrs) do
      device
      |> cast(attrs, [])
      |> add_error(
        :operating_system,
        "Only custom message for operating system",
        skip_field_name: true
      )
    end
  end

  test "given error code and an invalid changeset with multiple errors fields, renders error.json" do
    changeset = Device.changeset(%{})
    error = %{code: :validation_error, changeset: changeset}

    assert render(ErrorView, "error.json", error) ==
             %{
               errors: [
                 %{
                   code: :validation_error,
                   detail: "Device can't be blank",
                   source: %{parameter: :device_id}
                 },
                 %{
                   code: :validation_error,
                   detail: "Device name can't be blank",
                   source: %{parameter: :device_name}
                 },
                 %{
                   code: :validation_error,
                   detail: "Operating system can't be blank",
                   source: %{parameter: :operating_system}
                 }
               ]
             }
  end

  test "given error code and an invalid changeset with single error field, renders error.json" do
    changeset = Device.changeset(%{device_id: "12345678-9012", device_name: "Android"})
    error = %{code: :validation_error, changeset: changeset}

    assert render(ErrorView, "error.json", error) ==
             %{
               errors: [
                 %{
                   code: :validation_error,
                   detail: "Operating system can't be blank",
                   source: %{parameter: :operating_system}
                 }
               ]
             }
  end

  test "given error code and an invalid changeset that contains the `skip_field_name: true`, renders error.json" do
    changeset = Device.custom_error_changeset(%{})
    error = %{code: :validation_error, changeset: changeset}

    assert render(ErrorView, "error.json", error) ==
             %{
               errors: [
                 %{
                   code: :validation_error,
                   detail: "Only custom message for operating system",
                   source: %{parameter: :operating_system}
                 }
               ]
             }
  end
end
