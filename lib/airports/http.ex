defmodule Airports.Http do
  @callback get(binary(), keyword()) ::
              {:ok, %{status: integer(), body: binary()}} | {:error, term()}
end
