defmodule Engweb.Uploaders.ImageUploader do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @allowed_extensions ~w(.png .jpg .jpeg)

  def filename(version, {file, _post}) do
    # It is desirable for this name to be unique
    "#{file.file_name}_#{version}"
  end

  def validate(_version, {file, _scope}) do
    file_extension =
      file.file_name
      |> Path.extname()
      |> String.downcase()

    Enum.member?(@allowed_extensions, file_extension)
  end
end
