defmodule PlaymaMeSignalingWeb.Schema do
  use Absinthe.Schema

  import_types PlaymaMeSignalingWeb.Schema.Types

  alias PlaymaMeSignalingWeb.Resolvers

  query do
    field :session_token, :string do
      resolve(&Resolvers.Session.get_session_token/2)
    end

    field :user, :user do
      resolve(&Resolvers.User.get/2)
    end

    field :channel, :channel do
      arg(:channel_id, non_null(:string))

      resolve(&Resolvers.Channel.get/2)
    end
  end

  mutation do
    field :touch_channel, :channel do
      arg(:channel_name, non_null(:string))

      resolve(&Resolvers.Channel.touch/2)
    end

    field :join_channel, :channel do
      arg(:channel_name, non_null(:string))

      resolve(&Resolvers.Channel.join/2)
    end

    field :signaling, :signal do
      arg(:peer_uuid, non_null(:string))
      arg(:channel_name, non_null(:string))
      arg(:sdp, :string)
      arg(:type, :string)
      arg(:candidate, :string)

      resolve(fn args, res ->
        {:ok, args}
      end)
    end
  end

  subscription do
    field :signal_received, :signal do
      arg(:channel_name, non_null(:string))

      config(fn args, _ ->
        {:ok, topic: "#{args.channel_name}"}
      end)

      trigger(
        :signaling,
        topic: fn %{channel_name: channel_name} ->
          channel_name
        end
      )

      resolve(fn signal, _, _ ->
        {:ok, signal}
      end)
    end
  end
end
