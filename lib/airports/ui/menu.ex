defmodule Airports.UI.Menu do
  @moduledoc """
  Non-fullscreen arrow-key menu with paging/scrolling.

  Controls:
    - ↑ / ↓ : move
    - PgUp / PgDn : page up/down (when terminal sends standard sequences)
    - space / b : page down/up (less-style fallback)
    - g / G : top / bottom
    - Enter : select
    - q / Ctrl+C / EOF : cancel
  """

  alias Airports.UI.{Menu.State, Menu.Renderer, Terminal}

  @type item :: term() | {binary(), term()}
  @type result :: {:ok, term()} | {:error, :cancelled | :no_items}

  @spec select(binary(), [item()], keyword()) :: result()
  def select(prompt, items, opts \\ [])
  def select(_prompt, [], _opts), do: {:error, :no_items}
  def select(prompt, items, opts) when is_binary(prompt) and is_list(items) do
    page_size = Terminal.page_size(opts)
    state = State.init(length(items), page_size)

    Terminal.with_raw_mode(fn ->
      IO.write(["\r\n", prompt, "\r\n", Renderer.frame(items, state)])
      loop(items, state)
    end)
  end

  defp loop(items, %State{} = state) do
    case Terminal.read_action() do
      :enter ->
        {:ok, items |> Enum.at(state.idx) |> unwrap_value()}

      :cancel ->
        {:error, :cancelled}

      action ->
        new_state = State.step(state, action)

        if new_state != state do
          IO.write([IO.ANSI.cursor_up(state.page_size + 1), Renderer.frame(items, new_state)])
        end

        loop(items, new_state)
    end
  end

  defp unwrap_value({_label, value}), do: value
  defp unwrap_value(value), do: value
end

