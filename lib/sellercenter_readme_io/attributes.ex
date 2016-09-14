defmodule SellercenterReadmeIo.Attributes do
  @moduledoc false

  require Map
  require SellercenterReadmeIo

  def query(channel, primary_category) do
    method = :get
    url = channel["url"]
    body = ""
    headers = []
    params = %{
      "Action" => "GetCategoryAttributes",
      "PrimaryCategory" => primary_category,
    }
    params = SellercenterReadmeIo.get_params(channel, params)
    options = [
      {:params, params}
    ]
    response = SellercenterReadmeIo.parse_http(HTTPoison.request(method, url, body, headers, options))
    response = parse_http(channel, response)
    response
  end

  def parse_http(channel, {:ok, %{"SuccessResponse" => success_response}}) do
    response = {:ok, success_response}
    response = parse_http(channel, response)
    response
  end

  def parse_http(channel, {:ok, %{"Body" => body}}) do
    response = {:ok, body}
    response = parse_http(channel, response)
    response
  end

  def parse_http(channel, {:ok, %{"Attribute" => attributes}}) do
    attributes = Enum.map(attributes, fn(attribute) -> get_attribute(channel, attribute) end)
    attributes = Enum.uniq(attributes)
    {:ok, attributes}
  end

  def parse_http(channel, {:ok, %{"ErrorResponse" => error_response}}) do
    response = {:ok, error_response}
    response = parse_http(channel, response)
    response
  end

  def parse_http(channel, {:ok, %{"Head" => head}}) do
    response = {:ok, head}
    response = parse_http(channel, response)
    response
  end

  def parse_http(_channel, {:ok, %{"ErrorCode" => error_code}}) do
    {:ok, error_code}
  end

  def parse_http(_channel, {:ok, _attributes}) do
    {:error, ""}
  end

  def parse_http(_channel, {:error, reason}) do
    {:error, reason}
  end

  def get_attribute(channel, attribute) do
    {name, name_es} = get_names(channel, attribute)
    {description, description_es} = get_descriptions(channel, attribute)
    is_mandatory = get_is_mandatory(attribute)
    options = get_options(channel, attribute)
    type = get_type(options, attribute)
    %{
      "name" => name,
      "name_es" => name_es,
      "description" => description,
      "description_es" => description_es,
      "is_mandatory" => is_mandatory,
      "type" => type,
      "options" => options,
    }
  end

  def get_names(%{"language" => "en"}, attribute) do
    {attribute["Label"], ""}
  end

  def get_names(%{"language" => "es"}, attribute) do
    {"", attribute["Label"]}
  end

  def get_names(_channel, attribute) do
    {attribute["Label"], ""}
  end

  def get_descriptions(%{"language" => "en"}, attribute) do
    {attribute["Description"], ""}
  end

  def get_descriptions(%{"language" => "es"}, attribute) do
    {"", attribute["Description"]}
  end

  def get_descriptions(_channel, attribute) do
    {attribute["Description"], ""}
  end

  def get_is_mandatory(%{"isMandatory" => "0"}) do
    false
  end

  def get_is_mandatory(%{"isMandatory" => "1"}) do
    true
  end

  def get_is_mandatory(_) do
    false
  end

  def get_type([], %{"InputType" => "checkbox"}) do
    ~s(input[type="checkbox"])
  end

  def get_type([], %{"InputType" => "datefield"}) do
    ~s(input[type="date"])
  end

  def get_type([], %{"InputType" => "datetime"}) do
    ~s(input[type="datetime"])
  end

  def get_type([], %{"InputType" => "dropdown"}) do
    ~s(select)
  end

  def get_type([], %{"InputType" => "multiselect"}) do
    ~s(select[multiple="multiple"])
  end

  def get_type([], %{"InputType" => "numberfield"}) do
    ~s(input[type="number"])
  end

  def get_type([], %{"InputType" => "textarea"}) do
    ~s(textarea)
  end

  def get_type([], %{"InputType" => "textfield"}) do
    ~s(input[type="text"])
  end

  def get_type([], _type) do
    ~s(input[type="text"])
  end

  def get_type(_options, _type) do
    "select"
  end

  def get_options(channel, %{"Options" => options}) do
    options = get_options(channel, options)
    options
  end

  def get_options(channel, %{"Option" => options}) do
    options = get_options(channel, options)
    options
  end

  def get_options(_channel, "") do
    []
  end

  def get_options(channel, options) do
    options = Enum.map(options, fn(option) -> get_option(channel, option) end)
    options = Enum.uniq(options)
    options
  end

  def get_option(%{"language" => "en"}, option) do
    {option["Name"], option["Name"]}
  end

  def get_option(%{"language" => "es"}, option) do
    {option["Name"], ""}
  end

  def get_option(_channel, option) do
    {option["Name"], option["Name"]}
  end
end
