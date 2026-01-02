defmodule Airports.HttpStub do
  def get(url, _opts) do
    send(self(), {:http_get, url})

    case Process.get({__MODULE__, :mode}, :ok) do
      :ok ->
        ok_response(url)

      :http_404 ->
        {:ok, %{status: 404, body: ""}}

      :error ->
        {:error, :boom}
    end
  end

  defp ok_response(url) do
    cond do
      String.contains?(url, "index.xml") ->
        {:ok, %{status: 200, body: "<wx_station_index></wx_station_index>"}}

      String.contains?(url, "/KJFK.xml") ->
        {:ok,
         %{status: 200, body: """
         <current_observation>
           <station_id>KJFK</station_id>
           <location>NYC</location>
           <weather>Fair</weather>
           <observation_time>Now</observation_time>
           <temperature_string>0 C</temperature_string>
           <wind_string>Calm</wind_string>
         </current_observation>
         """}}

      true ->
        {:ok, %{status: 404, body: ""}}
    end
  end
end
