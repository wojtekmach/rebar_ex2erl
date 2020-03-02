defmodule :spdx do
  json_path = Path.expand("../license-list-data/json/licenses.json", __DIR__)

  json =
    case File.read(json_path) do
      {:ok, json} ->
        json

      {:error, :enoent} ->
        IO.puts("#{json_path} not found, run `git submodule init && git submodule update`")
        System.halt(1)
    end

  data = :jsx.decode(json, [:return_maps])

  @version data["licenseListVersion"]

  def version() do
    @version
  end

  @license_ids Enum.map(data["licenses"], & &1["licenseId"])

  def license_ids() do
    @license_ids
  end
end
