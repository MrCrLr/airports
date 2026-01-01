defmodule Airports.UI.Menu.State do
  @moduledoc """
  Pure state for Menu: selection index and scroll window.

  This module should have no IO and be easy to unit test.
  """

  @enforce_keys [:idx, :start, :page_size, :n]
  defstruct [:idx, :start, :page_size, :n]

  @type t :: %__MODULE__{
          idx: non_neg_integer(),
          start: non_neg_integer(),
          page_size: pos_integer(),
          n: non_neg_integer()
        }

  @spec init(non_neg_integer(), pos_integer()) :: t()
  def init(n, page_size) when is_integer(n) and n >= 0 do
    %__MODULE__{idx: 0, start: 0, page_size: page_size, n: n}
  end

  @spec step(t(), term()) :: t()
  def step(%__MODULE__{} = s, :up) do
    new_idx = max(s.idx - 1, 0)
    %{s | idx: new_idx, start: clamp_start(new_idx, s.start, s.page_size, s.n)}
  end

  def step(%__MODULE__{} = s, :down) do
    new_idx = min(s.idx + 1, max(s.n - 1, 0))
    %{s | idx: new_idx, start: clamp_start(new_idx, s.start, s.page_size, s.n)}
  end

  def step(%__MODULE__{} = s, :page_down) do
    new_idx = min(s.idx + s.page_size, max(s.n - 1, 0))
    %{s | idx: new_idx, start: clamp_start(new_idx, s.start, s.page_size, s.n)}
  end

  def step(%__MODULE__{} = s, :page_up) do
    new_idx = max(s.idx - s.page_size, 0)
    %{s | idx: new_idx, start: clamp_start(new_idx, s.start, s.page_size, s.n)}
  end

  def step(%__MODULE__{} = s, :home) do
    %{s | idx: 0, start: 0}
  end

  def step(%__MODULE__{} = s, :end) do
    new_idx = max(s.n - 1, 0)
    new_start = max(s.n - s.page_size, 0)
    %{s | idx: new_idx, start: new_start}
  end

  def step(%__MODULE__{} = s, _other), do: s

  # Keep idx visible inside [start, start + page_size - 1]
  defp clamp_start(idx, start, page_size, n) do
    max_start = max(n - page_size, 0)

    cond do
      idx < start ->
        idx

      idx >= start + page_size ->
        min(idx - page_size + 1, max_start)

      true ->
        min(start, max_start)
    end
  end
end
