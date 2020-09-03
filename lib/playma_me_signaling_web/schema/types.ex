defmodule PlaymaMeSignalingWeb.Schema.Types do
  use Absinthe.Schema.Notation

  scalar :timestamp, name: "DateTime" do
    serialize(&serialize_timestamp/1)
    parse(&parse_timestamp/1)
  end

  object :signal do
    field(:peer_uuid, :string)
    field(:channel_name, :string)
    field(:candidate, :string)
    field(:sdp, :string)
    field(:type, :string)
  end

  object :channel do
    field(:id, :string)
    field(:name, :string)
    field(:user_id, :string)
    field(:messages, list_of(:message))
    field(:users, list_of(:user))
  end

  object :user do
    field(:id, :string)
    field(:name, :string)
    field(:created_at, :timestamp)
  end

  object :message do
    field(:id, :string)
    field(:message, :string)
    field(:user_id, :string)
    field(:created_at, :timestamp)
  end

  def serialize_timestamp(%DateTime{} = timestamp),
    do: DateTime.to_iso8601(timestamp)

  def parse_timestamp(%Absinthe.Blueprint.Input.String{value: value}) do
    case DateTime.from_iso8601(value) do
      {:ok, datetime, 0} -> {:ok, datetime}
      _error -> :error
    end
  end

  def parse_timestamp(%Absinthe.Blueprint.Input.Null{}) do
    {:ok, nil}
  end

  def parse_timestamp(_) do
    :error
  end
end
