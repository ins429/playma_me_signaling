defmodule PlaymaMeSignaling.Channels.Channel do
  @enforce_keys [:id, :user_id]
  defstruct [
    :id,
    :name,
    :user_id,
    :updated_at,
    :last_active_at,
    :pid,
    users: []
  ]

  alias PlaymaMeSignaling.{
    Channels,
    Channels.Channel,
    Users,
    Users.User
  }

  use GenServer

  def start_link(state, opts) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  @impl true
  def init({user, name}) do
    schedule_health_check()

    state = %Channel{
      id: name,
      name: name,
      user_id: user.id,
      users: [user],
      last_active_at: DateTime.utc_now(),
      pid: self()
    }

    {:ok, state}
  end

  @impl true
  def handle_call(
        {:join, %User{id: user_id} = user},
        _from,
        %{users: []} = state
      ) do
    new_state = %{
      state
      | users: [user],
        user_id: user_id,
        last_active_at: DateTime.utc_now()
    }

    {:reply, new_state, new_state}
  end

  def handle_call(
        {:join, %User{id: user_id} = user},
        _from,
        state
      ) do
    new_state = %{
      state
      | users: state.users ++ [user],
        last_active_at: DateTime.utc_now()
    }

    {:reply, new_state, new_state}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  @five_minutes 300
  @two_minutes 120
  @impl true
  def handle_info(
        :health_check,
        %__MODULE__{last_active_at: last_active_at} = state
      ) do
    schedule_health_check()

    DateTime.utc_now()
    |> DateTime.diff(last_active_at)
    |> case do
      diff when diff > @five_minutes ->
        {:stop, :normal, state}

      diff ->
        {:noreply, state}
    end
  end

  @impl true
  def handle_call(:touch, _from, state) do
    new_state = %{state | last_active_at: DateTime.utc_now()}
    {:reply, new_state, new_state}
  end

  @impl true
  def handle_info(:kill, state) do
    {:stop, :normal, state}
  end

  @impl true
  def terminate(reason, %__MODULE__{} = state) do
    IO.inspect(reason)
    Channels.destroy(self())
  end

  defp schedule_health_check do
    Process.send_after(self(), :health_check, 5_000)
  end

  defp publish_channel_updated(state) do
    Task.start(fn ->
      Absinthe.Subscription.publish(PlaymaMeSignalingWeb.Endpoint, state,
        channel_updated: state.id
      )
    end)
  end

  defp publish_channel_updated(state, true) do
    publish_channel_updated(state)
  end

  defp publish_channel_updated(_state, false), do: :ignore
end
