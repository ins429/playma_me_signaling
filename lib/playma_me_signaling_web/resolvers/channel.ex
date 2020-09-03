defmodule PlaymaMeSignalingWeb.Resolvers.Channel do
  alias PlaymaMeSignaling.{
    Users,
    Channels,
    Channels.Channel
  }

  def join(%{channel_name: channel_name}, %{context: %{viewer: user}}) do
    with {:ok, %Channel{} = channel} <- Channels.get(channel_name) do
      IO.puts("\n\n\n\n0\n\n\n\n")

      cond do
        Enum.member?(channel.users, user) ->
          IO.puts("\n\n\n\n1\n\n\n\n")
          {:ok, channel}

        length(channel.users) > 1 ->
          IO.puts("\n\n\n\n2\n\n\n\n")
          {:error, :full}

        true ->
          IO.puts("\n\n\n\n3\n\n\n\n")
          Channels.join(channel.pid, user)
      end
    else
      {:error, :not_found} ->
        IO.puts("\n\n\n\n4\n\n\n\n")

        Channels.create(user, channel_name)
        |> Channels.get()

      {:error, reason} ->
        IO.puts("\n\n\n\n5\n\n\n\n")
        {:error, reason}
    end
  end

  def touch(%{channel_name: channel_name}, %{context: %{viewer: user}}) do
  end
end
