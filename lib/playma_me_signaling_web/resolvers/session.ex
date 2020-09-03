defmodule PlaymaMeSignalingWeb.Resolvers.Session do
  alias PlaymaMeSignaling.Users

  @diff 3600
  def get_session_token(args, %{context: context} = _absinthe_res) do
    PlaymaMeSignalingWeb.Guardian.decode_and_verify(context.current_token)
    |> case do
      {:ok, %{"exp" => exp}} ->
        DateTime.from_unix!(exp)
        |> DateTime.diff(DateTime.utc_now())
        |> case do
          diff when diff < @diff ->
            {:ok, _old_stuff, {new_token, new_claims}} =
              PlaymaMeSignalingWeb.Guardian.refresh(context.current_token,
                ttl: {1, :week}
              )

            # Users.update_token(context.viewer.id, new_token)

            {:ok, new_token}

          _ ->
            {:ok, context.current_token}
        end

      _ ->
        {:ok, context.current_token}
    end
  end
end
