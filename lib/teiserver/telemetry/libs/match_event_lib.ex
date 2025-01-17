defmodule Teiserver.Telemetry.MatchEventLib do
  use CentralWeb, :library
  alias Teiserver.Telemetry.MatchEvent

  # Functions
  @spec colour :: atom
  def colour(), do: :info2

  @spec icon() :: String.t()
  def icon(), do: "fa-regular fa-match"

  # Queries
  @spec query_match_events() :: Ecto.Query.t()
  def query_match_events do
    from(match_events in MatchEvent)
  end

  @spec search(Ecto.Query.t(), Map.t() | nil) :: Ecto.Query.t()
  def search(query, nil), do: query

  def search(query, params) do
    params
    |> Enum.reduce(query, fn {key, value}, query_acc ->
      _search(query_acc, key, value)
    end)
  end

  @spec _search(Ecto.Query.t(), Atom.t(), any()) :: Ecto.Query.t()
  def _search(query, _, ""), do: query
  def _search(query, _, nil), do: query

  def _search(query, :user_id, user_id) do
    from match_events in query,
      where: match_events.user_id == ^user_id
  end

  def _search(query, :user_id_in, user_ids) do
    from match_events in query,
      where: match_events.user_id in ^user_ids
  end

  def _search(query, :id_list, id_list) do
    from match_events in query,
      where: match_events.id in ^id_list
  end

  def _search(query, :between, {start_date, end_date}) do
    from match_events in query,
      where: between(match_events.timestamp, ^start_date, ^end_date)
  end

  def _search(query, :event_type_id, event_type_id) do
    from match_events in query,
      where: match_events.event_type_id == ^event_type_id
  end

  def _search(query, :event_type_id_in, event_type_ids) do
    from match_events in query,
      where: match_events.event_type_id in ^event_type_ids
  end

  @spec order_by(Ecto.Query.t(), String.t() | nil) :: Ecto.Query.t()
  def order_by(query, nil), do: query

  def order_by(query, "Name (A-Z)") do
    from match_events in query,
      order_by: [asc: match_events.name]
  end

  def order_by(query, "Name (Z-A)") do
    from match_events in query,
      order_by: [desc: match_events.name]
  end

  def order_by(query, "Newest first") do
    from match_events in query,
      order_by: [desc: match_events.inserted_at]
  end

  def order_by(query, "Oldest first") do
    from match_events in query,
      order_by: [asc: match_events.inserted_at]
  end

  @spec preload(Ecto.Query.t(), List.t() | nil) :: Ecto.Query.t()
  def preload(query, nil), do: query

  def preload(query, preloads) do
    query = if :event_type in preloads, do: _preload_event_types(query), else: query
    query = if :user in preloads, do: _preload_users(query), else: query
    query = if :match in preloads, do: _preload_matches(query), else: query
    query
  end

  @spec _preload_event_types(Ecto.Query.t()) :: Ecto.Query.t()
  def _preload_event_types(query) do
    from match_events in query,
      left_join: event_types in assoc(match_events, :event_type),
      preload: [event_type: event_types]
  end

  @spec _preload_users(Ecto.Query.t()) :: Ecto.Query.t()
  def _preload_users(query) do
    from match_events in query,
      left_join: users in assoc(match_events, :user),
      preload: [user: users]
  end

  @spec _preload_matches(Ecto.Query.t()) :: Ecto.Query.t()
  def _preload_matches(query) do
    from match_events in query,
      left_join: matches in assoc(match_events, :match),
      preload: [match: matches]
  end
end
