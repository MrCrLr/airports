defmodule Airports.UI.Terminal do
  @moduledoc """
  Terminal IO concerns: raw mode, key decoding, page sizing.

  Keep platform/terminal weirdness here.
  """

  @single_keys %{
    <<3>>    => :cancel,   # Ctrl+C (ETX)
    <<"q">>  => :cancel,
    <<"\r">> => :enter,
    <<"\n">> => :enter,
    <<" ">>  => :page_down,
    <<"b">>  => :page_up,
    <<"g">>  => :home,
    <<"G">>  => :end
  }

  @spec with_raw_mode((-> any())) :: any()
  def with_raw_mode(fun) when is_function(fun, 0) do
    :shell.start_interactive({:noshell, :raw})

    try do
      fun.()
    after
      :shell.start_interactive({:noshell, :cooked})
      IO.write("\n")
    end
  end

  @spec page_size(keyword()) :: pos_integer()
  def page_size(opts \\ []) do
    desired = Keyword.get(opts, :page_size, default_page_size())
    normalize_page_size(desired)
  end

  @spec read_action() :: :up | :down | :page_up | :page_down | :home | :end | :enter | :cancel | :unknown
  def read_action do
    read_bytes(1) |> decode_key()
  end

  # ---- sizing ----

  defp default_page_size do
    rows =
      case :io.rows() do
        {:ok, r} when is_integer(r) and r > 0 -> r
        _ -> 24
      end

    # Reserve prompt + spacing + footer, keep a minimum
    max(rows - 6, 6)
  end

  defp normalize_page_size(n) when is_integer(n), do: min(max(n, 6), 50)
  defp normalize_page_size(_), do: 10

  # ---- decoding ----

  defp decode_key(:eof), do: :cancel

  # ESC sequences
  defp decode_key(<<27>>) do
    case read_bytes(1) do
      <<"[">> -> decode_csi()
      _ -> :unknown
    end
  end

  defp decode_key(bin), do: Map.get(@single_keys, bin, :unknown)

  # Common CSI sequences:
  #   ESC [ A / B  (arrows)
  #   ESC [ 5 ~    (PageUp)
  #   ESC [ 6 ~    (PageDown)
  #   ESC [ H / F  (Home/End) on some terminals
  #   ESC [ 1 ~ / 4 ~ (Home/End) on others
  defp decode_csi do
    case read_bytes(1) do
      <<"A">> -> :up
      <<"B">> -> :down
      <<"H">> -> :home
      <<"F">> -> :end
      <<"5">> -> if read_bytes(1) == <<"~">>, do: :page_up, else: :unknown
      <<"6">> -> if read_bytes(1) == <<"~">>, do: :page_down, else: :unknown
      <<"1">> -> if read_bytes(1) == <<"~">>, do: :home, else: :unknown
      <<"4">> -> if read_bytes(1) == <<"~">>, do: :end, else: :unknown
      _ -> :unknown
    end
  end

  defp read_bytes(n) do
    case :io.get_chars(:standard_io, ~c"", n) do
      :eof -> :eof
      data -> IO.iodata_to_binary(data)
    end
  end
end

