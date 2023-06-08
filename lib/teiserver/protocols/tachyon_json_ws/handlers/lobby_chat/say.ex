defmodule Teiserver.Tachyon.Handlers.LobbyChat.Say do
  @moduledoc """
  Handler for lobby chat "say" command
  """
  alias Teiserver.Data.Types, as: T
  alias Teiserver.Tachyon.Responses.LobbyChat.SayResponse

  @spec dispatch_handlers :: map()
  def dispatch_handlers() do
    %{
      "lobbyChat/say/request" => &execute/3
    }
  end

  @spec execute(T.tachyon_conn(), map, map) ::
          {{T.tachyon_command(), T.tachyon_object()}, T.tachyon_conn()}
  def execute(conn, object, meta) do

    # TODO: check lobby ID

    IO.inspect(conn, label: "conn")
    if Lobby.allow?(conn.userid, :saybattle, conn.lobby_id) do
      Lobby.say(meta.userid, object.message, meta.lobby_id)
    end

    response = SayResponse.generate({:success, %{}})
    {response, conn}
  end
end
