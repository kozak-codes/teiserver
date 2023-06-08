defmodule Teiserver.Tachyon.Responses.LobbyChat.SayResponse do
  @moduledoc """

  """

  alias Teiserver.Data.Types, as: T

  @spec generate({:error, String.t()} | T.lobby()) :: {T.tachyon_command(), T.tachyon_object()}
  def generate({:error, reason}) do
    {"system/error/response", :error, reason}
  end

  def generate({:failed, reason}) do
    {"lobby/say/response", :failed, %{"result" => "failure", "reason" => reason}}
  end

  def generate({:success, result}) do
    {"lobby/say/response", :success, %{ success: result }}
  end
end
