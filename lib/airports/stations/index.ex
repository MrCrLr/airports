defmodule Airports.Stations.Index do

  @index_url Application.compile_env!(:airports, :index_url)

  def fetch do
    case Req.get(@index_url) do
      {:ok, %{status: 200, body: body}} ->
        {:ok, body}

      {:ok, %{status: status}} ->
        {:error, {:http_error, status}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
