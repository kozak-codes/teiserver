defmodule Teiserver.Game.AchievementServer do
  use GenServer
  alias Phoenix.PubSub
  alias Teiserver.Game
  require Logger

  @scenario_lookup %{
    "001 - A helping hand" => "archsimkatshelpers017",
    "002 - A head start" => "Fallendellheadstart008",
    "003 - Testing the waters" => "shoretoshorevsbarb013",
    "004 - A safe haven" => "pinewoodvsbarb014",
    "005 - Mines, all mine!" => "avalanchemines012",
    "006 - Back from the dead" => "Tundrabackfromthedead009",
    "007 - King of the hill" => "thronekoth015",
    "008 - Keep your secrets" => "strongholdkilltraitor010",
    "009 - Outsmart the barbarians" => "supcrossingvsbarbs001",
    "010 - World war XXV" => "neuropeww225",
    "011 - Steal Cortex's tech" => "stealtech005",
    "012 - One robot army" => "pinewoodfatboy018",
    "013 - One by one" => "tma20ffabarbs",
    "014 - The sky is the limit" => "acidicquarrybarbs",
    "015 - David vs Goliath" => "glaciergoliath018",
    # "016 - A final stand" => "",
    "017 - Infantry simulator" => "twobarbspwakonly006",
    "018 - Tick tock" => "SpeedMetalSnipe011",
    "019 - Catch those rare comets" => "threebarbscomet",
  }

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  @impl true
  def handle_info({:teiserver_telemetry_client_events,
    userid, "game_start:singleplayer:scenario_end", %{
    "scenarioid" => scenarioid,
    "difficulty" => difficulty,
    "won" => true
  }}, state) do
    if Enum.member?(["Normal", "Hard", "Brutal"], difficulty) do
      type_id = state.normal_scenario_map[scenarioid]
      if Game.get_user_achievement(userid, type_id) == nil do
        Game.create_user_achievement(%{
          user_id: userid,
          achievement_type_id: type_id,
          achieved: true,
          inserted_at: Timex.now()
        })
      end
    end

    if Enum.member?(["Brutal"], difficulty) do
      type_id = state.brutal_scenario_map[scenarioid]
      if Game.get_user_achievement(userid, type_id) == nil do
        Game.create_user_achievement(%{
          user_id: userid,
          achievement_type_id: type_id,
          achieved: true,
          inserted_at: Timex.now()
        })
      end
    end

    {:noreply, state}
  end

  def handle_info({:teiserver_telemetry_client_events, _, type, value}, state) do
    Logger.info("No AchievementServer handler for #{type} - #{Kernel.inspect value}")
    {:noreply, state}
  end

  def handle_info(:refresh_type_map, state) do
    {:noreply, do_refresh_type_map(state)}
  end

  defp do_refresh_type_map(state) do
    normal_scenario_map = Game.list_achievement_types(search: [
      grouping: "Single player scenarios (Normal)"
    ],
      limit: :infinity,
      select: [:id, :name]
    )
    |> Map.new(fn at ->
      lookup_name = String.replace(at.name, " (Normal)", "")
      {@scenario_lookup[lookup_name], at.id}
    end)

    brutal_scenario_map = Game.list_achievement_types(search: [
      grouping: "Single player scenarios (Brutal)"
    ],
      limit: :infinity,
      select: [:id, :name]
    )
    |> Map.new(fn at ->
      lookup_name = String.replace(at.name, " (Brutal)", "")
      {@scenario_lookup[lookup_name], at.id}
    end)

    %{state |
      normal_scenario_map: normal_scenario_map,
      brutal_scenario_map: brutal_scenario_map
    }
  end

  @impl true
  def init(_) do
    :timer.send_after(10_000, :refresh_type_map)
    :ok = PubSub.subscribe(Central.PubSub, "teiserver_telemetry_client_events")
    :timer.send_interval(300_000, :refresh_type_map)
    {:ok, %{
      normal_scenario_map: %{},
      brutal_scenario_map: %{}
    }}
  end
end