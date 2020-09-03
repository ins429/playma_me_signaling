defmodule PlaymaMeSignalingWeb.Guardian do
  use Guardian, otp_app: :playma_me_signaling

  alias PlaymaMeSignaling.Users
  alias PlaymaMeSignaling.Users.User

  def subject_for_token(%User{id: id}, _claims) do
    {:ok, "User:#{id}"}
  end

  def subject_for_token(id, _claims) do
    {:ok, "User:#{id}"}
  end

  def subject_for_token(_, _), do: {:error, :unhandled_resource_type}

  def resource_from_claims(%{"sub" => "User:" <> id}) do
    case Users.get(id) do
      {:error, _} -> {:error, :resource_not_found}
      user -> {:ok, user}
    end
  end

  def resource_from_claims(_), do: {:error, :unhandled_resource_type}
end
