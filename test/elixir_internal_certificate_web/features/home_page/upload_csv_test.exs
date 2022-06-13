defmodule ElixirInternalCertificateWeb.HomePage.UploadCSVTest do
  use ElixirInternalCertificateWeb.FeatureCase, async: true

  feature("uploading page", %{session: session},
    do:
      session
      |> login_user()
      |> assert_has(Query.text("Select CSV file, maximum 100 keywords contained"))
      |> assert_has(Query.css(".btn.btn-primary.btn-block.ms-2", text: "Upload"))
      |> assert_has(Query.css("#keyword-upload-form_file"))
  )

  feature "upload file", %{session: session} do
    upload_field = Query.file_field("file")

    session
    |> login_user()
    |> attach_file(upload_field, path: "test/support/assets/files/upload.csv")
    |> take_screenshot()

    find(
      session,
      upload_field,
      &assert(
        &1
        |> Wallaby.Element.value()
        |> String.ends_with?("upload.csv")
      )
    )
  end
end
