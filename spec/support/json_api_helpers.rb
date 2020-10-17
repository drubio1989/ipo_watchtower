module JsonApiHelper
  def json
    JSON.parse(response.body)
  end

  def json_data
    json["data"]
  end

  def json_included
    json["included"]
  end

  def json_pagination
    json["links"]
  end
end
