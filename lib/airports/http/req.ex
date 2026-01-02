defmodule Airports.Http.Req do
  @behaviour Airports.Http

  @impl true
  def get(url, opts \\ []) do
    case Req.get(url, opts) do
      {:ok, %{status: status, body: body}} -> {:ok, %{status: status, body: body}}
      {:ok, %{status: status}} -> {:ok, %{status: status, body: ""}}
      {:error, reason} -> {:error, reason}
    end
  end
end
