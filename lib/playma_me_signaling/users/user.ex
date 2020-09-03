defmodule PlaymaMeSignaling.Users.User do
  alias PlaymaMeSignaling.{
    Users,
    Channels,
    Channels.Channel
  }

  use GenServer, restart: :transient

  @enforce_keys [
    :id,
    :name,
    :created_at,
    :last_active_at
  ]
  defstruct [
    :id,
    :name,
    :created_at,
    :last_active_at
  ]

  def start_link({id, name}, opts) do
    GenServer.start_link(__MODULE__, {id, name}, opts)
  end

  def start_link(%__MODULE__{} = state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def new(id, name) do
    %__MODULE__{
      id: id,
      name: "#{name}-#{inspect(self)}",
      created_at: DateTime.utc_now(),
      last_active_at: DateTime.utc_now()
    }
  end

  def new(%__MODULE__{} = state) do
    state
  end

  @impl true
  def init({id, name}) do
    schedule_health_check()

    {:ok, new(id, name)}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_cast({:set_name, name}, state) do
    {:noreply, %{state | name: name, last_active_at: DateTime.utc_now()}}
  end

  @impl true
  def handle_cast(:touch, state) do
    {:noreply, %{state | last_active_at: DateTime.utc_now()}}
  end

  #
  # health check
  #
  @five_minutes 300
  @impl true
  def handle_info(:health_check, state) do
    DateTime.utc_now()
    |> DateTime.diff(state.last_active_at)
    |> case do
      diff when diff > @five_minutes ->
        {:stop, :normal, state}

      diff ->
        {:noreply, state}
    end
  end

  @impl true
  def terminate(_, %__MODULE__{name: name}) do
    Users.destroy(self())
  end

  defp schedule_health_check do
    Process.send_after(self(), :health_check, 30_000)
  end
end
