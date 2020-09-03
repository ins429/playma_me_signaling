defmodule PlaymaMeSignalingWeb.Resolvers.User do
  alias PlaymaMeSignaling.Users
  alias PlaymaMeSignaling.Users.User

  def get(_, %{context: %{viewer: viewer}}) do
    {:ok, viewer}
  end

  def set_name(%{name: name}, %{context: %{viewer: viewer}}) do
    Users.update_name(viewer.id, name)

    {:ok, %{viewer | name: name}}
  end

  def set_avatar(%{avatar: avatar}, %{context: %{viewer: viewer}}) do
    Users.update_avatar(viewer.id, avatar)

    {:ok, %{viewer | avatar: avatar}}
  end
end
