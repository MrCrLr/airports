defmodule Airports.MenuStub do
  def select(prompt, items) do
    send(self(), {:menu_select, prompt, items})
    {:ok, :stubbed}
  end
end
