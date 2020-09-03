defmodule PlaymaMeSignaling.Channels do
  alias PlaymaMeSignaling.Channels.Channel

  use Supervisor

  def start_link() do
    DynamicSupervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  @impl true
  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def which_children do
    __MODULE__
    |> DynamicSupervisor.which_children()
  end

  def all do
    which_children()
    |> Enum.map(&elem(&1, 1))
    |> Enum.reduce([], fn pid, acc ->
      get(pid)
      |> case do
        {:ok, channel} -> acc ++ [channel]
        {:error, _} -> acc
      end
    end)
  end

  def create(user, name) do
    DynamicSupervisor.start_child(__MODULE__, %{
      id: name,
      start: {Channel, :start_link, [{user, name}, [name: via_tuple(name)]]},
      restart: :transient
    })
    |> case do
      {:ok, pid} ->
        pid

      {:ok, pid, _} ->
        pid

      {:error, {:already_started, pid}} ->
        pid

      result ->
        IO.puts("unexpected result from Channels.create/1: #{inspect(result)}")
        result
    end
  end

  def destroy(name) do
    DynamicSupervisor.terminate_child(__MODULE__, name)
  end

  def get(pid) when is_pid(pid) do
    GenServer.call(pid, :get)
    |> case do
      nil ->
        {:error, :not_found}

      channel ->
        {:ok, channel}
    end
  end

  def get(name) when is_binary(name) do
    with {:ok, pid} <- find(name), do: get(pid)
  end

  def get(nil), do: {:error, :not_found}

  def join(pid, user) do
    GenServer.call(pid, {:join, user})
    |> case do
      %Channel{} = channel ->
        {:ok, channel}

      _err ->
        {:error, :not_found}
    end
  end

  defp find(name) do
    case Registry.lookup(PlaymaMeSignaling.ChannelRegistry, name) do
      [{pid, _}] ->
        {:ok, pid}

      _ ->
        {:error, :not_found}
    end
  end

  defp via_tuple(name) do
    {:via, Registry, {PlaymaMeSignaling.ChannelRegistry, name}}
  end
end
