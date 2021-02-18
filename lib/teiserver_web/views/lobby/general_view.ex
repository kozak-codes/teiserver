defmodule TeiserverWeb.Lobby.GeneralView do
  use TeiserverWeb, :view

  def colours(), do: StylingHelper.colours(:primary)
  def icon(), do: StylingHelper.icon(:primary)
end
