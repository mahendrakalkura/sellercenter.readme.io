defmodule SellercenterReadmeIo do
  @moduledoc false

  require Base
  require Enum
  require HTTPoison
  require JSX
  require Map
  require String
  require Timex
  require URI

  def get_params(channel, params_custom) do
    timestamp = get_timestamp()
    params_default = %{
      "Filter" => "all",
      "Format" => "JSON",
      "Timestamp" => timestamp,
      "UserID" => channel["user_id"],
      "Version" => "1.0",
    }
    params = Map.merge(params_default, params_custom)
    message = get_message(params)
    signature = get_signature(channel, message)
    params = Map.put(params, "Signature", signature)
    params = Enum.map(params, fn({key, value}) -> {key, value} end)
    params
  end

  def get_timestamp() do
    timestamp = Timex.now("UTC")
    {:ok, timestamp} = Timex.format(timestamp, "{ISO:Extended}")
    timestamp
  end

  def get_message(params) do
    message = Enum.map(params, fn({key, value}) -> {key, value} end)
    message = Enum.sort(message)
    message = URI.encode_query(message)
    message
  end

  def get_signature(channel, message) do
    signature = :crypto.hmac(:sha256, channel["api_key"], message)
    signature = Base.encode16(signature)
    signature = String.downcase(signature)
    signature
  end

  def parse_http({:ok, %HTTPoison.Response{status_code: 200, body: body}}) do
    response = JSX.decode(body)
    response
  end

  def parse_http({:ok, %HTTPoison.Response{status_code: status_code}}) do
    {:error, status_code}
  end

  def parse_http({:error, %HTTPoison.Error{reason: reason}}) do
    {:error, reason}
  end
end
