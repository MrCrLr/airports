defmodule Airports.UI.Menu.Renderer do
  @moduledoc """
  Rendering for Menu. Produces iodata only.
  """

  alias Airports.UI.Menu.State

  @col_reset IO.ANSI.cursor_left(999)

  @spec frame([term()], State.t()) :: iodata()
  def frame(items, %State{} = state) do
    visible = Enum.slice(items, state.start, state.page_size)

    lines =
      for row <- 0..(state.page_size - 1) do
        item = Enum.at(visible, row)

        [
          @col_reset,
          IO.ANSI.clear_line(),
          line(item, state.start + row == state.idx),
          "\r\n"
        ]
      end

    footer =
      [
        @col_reset,
        IO.ANSI.clear_line(),
        footer_line(state),
        "\r\n"
      ]

    [lines, footer]
  end

  defp line(nil, _selected?), do: ""  # pad blank lines so redraw is stable

  defp line(item, selected?) do
    label =
      case item do
        {text, _value} when is_binary(text) -> text
        _ -> to_string(item)
      end

    if selected?, do: "-> " <> label, else: "   " <> label
  end

  defp footer_line(%State{start: start, page_size: page_size, n: n, idx: idx}) do
    from = if n == 0, do: 0, else: start + 1
    to = min(start + page_size, n)

    "   (#{from}-#{to} of #{n})  ↑/↓ PgUp/PgDn  space/b  g/G  Enter  q   [#{idx + 1}]"
  end
end

