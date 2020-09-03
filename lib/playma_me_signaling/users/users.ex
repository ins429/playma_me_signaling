defmodule PlaymaMeSignaling.Users do
  alias PlaymaMeSignaling.Users.User

  use DynamicSupervisor

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

  def create(name \\ "Player") do
    id = UUID.uuid4()

    DynamicSupervisor.start_child(__MODULE__, %{
      id: id,
      start: {User, :start_link, [{id, name}, [name: via_tuple(id)]]},
      restart: :transient
    })

    {:ok, id}
  end

  def destroy(child_id) do
    DynamicSupervisor.terminate_child(__MODULE__, child_id)
  end

  def get_by_ids(ids) do
    Enum.reduce(ids, [], fn id, acc ->
      get(id)
      |> case do
        {:error, _} -> acc
        user -> acc ++ [user]
      end
    end)
  end

  def get(id) do
    with {:ok, pid} <- find_pid(id), do: GenServer.call(pid, :get)
  end

  def update_name(id, name) do
    with {:ok, pid} <- find_pid(id), do: GenServer.cast(pid, {:set_name, name})
  end

  defp find_pid(id) do
    case Registry.lookup(PlaymaMeSignaling.UserRegistry, id) do
      [{pid, foo}] ->
        {:ok, pid}

      [] ->
        {:error, :user_not_found}
    end
  end

  defp via_tuple(id) do
    {:via, Registry, {PlaymaMeSignaling.UserRegistry, id}}
  end
end
