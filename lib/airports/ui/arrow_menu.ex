defmodule Airports.UI.ArrowMenu do
  @moduledoc """
  Non-fullscreen arrow-key menu (arrow up/down + Enter).

  Controls:
    - ↑ / ↓ : move
    - Enter : select
    - q / Ctrl+C : cancel
  """

  @col_reset IO.ANSI.cursor_left(999)

  @type item :: term() | {binary(), term()}
  @type result :: {:ok, term()} | {:error, :cancelled | :no_items}

  @single_keys %{
    <<3>>    => :cancel, # Ctrl+C (ETX) - may not be delivered depending on VM flags
    <<"q">>  => :cancel,
    <<"\r">> => :enter,
    <<"\n">> => :enter
  }

  @spec select(binary(), [item()]) :: result()
  def select(_prompt, []), do: {:error, :no_items}

  def select(prompt, items) when is_binary(prompt) and is_list(items) do
    with_raw_mode(fn ->
      IO.write(["\r\n", prompt, "\r\n", frame(items, 0)])
      loop(items, 0)
    end)
  end

  # ---- Loop ----

  defp loop(items, idx) do
    n = length(items)

    case read_key() do
      :enter ->
        {:ok, items |> Enum.at(idx) |> unwrap_value()}

      :cancel ->
        {:error, :cancelled}

      key ->
        new_idx = move(key, idx, n)

        if new_idx != idx do
          IO.write([IO.ANSI.cursor_up(n), frame(items, new_idx)])
        end

        loop(items, new_idx)
    end
  end

  defp move(:up, idx, _n), do: max(idx - 1, 0)
  defp move(:down, idx, n), do: min(idx + 1, n - 1)
  defp move(_, idx, _n), do: idx

  defp unwrap_value({_label, value}), do: value
  defp unwrap_value(value), do: value

  # ---- Rendering (iodata) ----

  defp frame(items, idx) do
    for {item, i} <- Enum.with_index(items) do
      [
        @col_reset,
        IO.ANSI.clear_line(),
        line(item, i == idx),
        "\r\n"
      ]
    end
  end

  defp line(item, selected?) do
    label =
      case item do
        {text, _value} when is_binary(text) -> text
        _ -> to_string(item)
      end

    if selected? do
      "-> " <> label
    else
      "   " <> label
    end
  end

  # ---- Raw mode wrapper ----

  defp with_raw_mode(fun) do
    :shell.start_interactive({:noshell, :raw})

    try do
      fun.()
    after
      :shell.start_interactive({:noshell, :cooked})
      IO.write("\n")
    end
  end

  # ---- Key reading ----

  defp read_key do
    read_bytes(1) |> decode_key()
  end

  defp decode_key(:eof), do: :cancel
  defp decode_key(<<27>>), do: decode_arrow_seq(read_bytes(2))
  defp decode_key(bin), do: Map.get(@single_keys, bin, :unknown)

  defp decode_arrow_seq(<<"[A">>), do: :up
  defp decode_arrow_seq(<<"[B">>), do: :down
  defp decode_arrow_seq(_), do: :unknown

  defp read_bytes(n) do
    case :io.get_chars(:standard_io, ~c"", n) do
      :eof -> :eof
      data -> IO.iodata_to_binary(data)
    end
  end
end

