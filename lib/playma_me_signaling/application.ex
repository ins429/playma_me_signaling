defmodule PlaymaMeSignaling.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      # Start the endpoint when the application starts
      PlaymaMeSignalingWeb.Endpoint,
      # Starts a worker by calling: PlaymaMeSignaling.Worker.start_link(arg)
      # {PlaymaMeSignaling.Worker, arg},
      %{
        id: Absinthe.Subscription,
        start: {Absinthe.Subscription.Supervisor, :start_link, [PlaymaMeSignalingWeb.Endpoint]},
        type: :supervisor
      },
      %{
        id: PlaymaMeSignaling.Channels,
        start: {PlaymaMeSignaling.Channels, :start_link, []},
        type: :supervisor
      },
      %{
        id: PlaymaMeSignaling.Users,
        start: {PlaymaMeSignaling.Users, :start_link, []},
        type: :supervisor
      },
      {Registry, keys: :unique, name: PlaymaMeSignaling.ChannelRegistry},
      {Registry, keys: :unique, name: PlaymaMeSignaling.UserRegistry}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PlaymaMeSignaling.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    PlaymaMeSignalingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
