defmodule PlaymaMeSignalingWeb.Router do
  use PlaymaMeSignalingWeb, :router

  pipeline :persist_session do
    plug Guardian.Plug.Pipeline,
      module: PlaymaMeSignalingWeb.Guardian,
      error_handler: PlaymaMeSignalingWeb.Guardian.ErrorHandler

    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.LoadResource, allow_blank: true
    plug :upsert_session
  end

  scope "/" do
    pipe_through [
      :persist_session,
      PlaymaMeSignalingWeb.Plug.GraphQL
    ]

    forward "/graphql", Absinthe.Plug,
      schema: PlaymaMeSignalingWeb.Schema,
      json_codec: Phoenix.json_library()
  end

  def upsert_session(conn, _) do
    Guardian.Plug.current_resource(conn)
    |> case do
      nil ->
        {:ok, id} = PlaymaMeSignaling.Users.create()

        {:ok, token, full_claims} =
          PlaymaMeSignalingWeb.Guardian.encode_and_sign(id, %{}, ttl: {4, :hour})

        key = Guardian.Plug.Pipeline.fetch_key(conn, [])

        conn
        |> Guardian.Plug.put_current_token(token, key: key)
        |> Guardian.Plug.put_current_claims(full_claims, key: key)
        |> Guardian.Plug.LoadResource.call([])

      _ ->
        conn
    end
  end
end
