defmodule Teiserver.Tachyon.Handlers.Lobby.JoinRequest do
  @moduledoc """

  """
  alias Teiserver.Data.Types, as: T
  alias Teiserver.Battle
  alias Teiserver.Tachyon.Responses.Lobby.JoinResponse

  @spec dispatch_handlers :: map()
  def dispatch_handlers() do
    %{
      "lobby/join/request" => &execute/3
    }
  end

  @spec execute(T.tachyon_conn(), map, map) ::
          {{T.tachyon_command(), T.tachyon_object()}, T.tachyon_conn()}
  def execute(conn, %{"lobby_id" => lobby_id} = object, _meta) do
    result = Battle.can_join?(conn.userid, lobby_id, object["password"])

    Lobby.accept_join_request(conn.userid, lobby_id)
    Map.put(conn, :lobby_id, lobby_id)

    response = JoinResponse.generate(result)

    {response, conn}
  end
end
