defmodule PlaymaMeSignalingWeb.Resolvers.Channel do
  alias PlaymaMeSignaling.{
    Users,
    Channels,
    Channels.Channel
  }

  def join(%{channel_name: channel_name}, %{context: %{viewer: user}}) do
    with {:ok, %Channel{} = channel} <- Channels.get(channel_name) do
      cond do
        Enum.member?(channel.users, user) ->
          {:ok, channel}

        length(channel.users) > 1 ->
          {:error, :full}

        true ->
          Channels.join(channel.pid, user)
      end
    else
      {:error, :not_found} ->
        Channels.create(user, channel_name)
        |> Channels.get()

      {:error, reason} ->
        {:error, reason}
    end
  end

  def touch(%{channel_name: channel_name}, %{context: %{viewer: user}}) do
    with {:ok, channel} <- Channels.get(channel_name) |> IO.inspect(),
         {:ok, _} <- is_member?(channel, user) do
      Channels.touch(channel_name)
    end
  end

  def is_member?(channel, user) do
    channel.users
    |> Enum.map(& &1.id)
    |> Enum.member?(user.id)
    |> case do
      true -> {:ok, nil}
      false -> {:error, :not_allowed}
    end
  end
end
