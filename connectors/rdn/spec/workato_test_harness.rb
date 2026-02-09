require 'httparty'
require 'json'

module WorkatoTestHarness
  def post(endpoint, payload = {})
    url = "https://#{@connection['domain']}.simnang.com/api/public/api/1/#{endpoint}"
    headers = {
      "Authorization" => "Bearer #{@connection['api_key']}",
      "Autopal-Instance-ID" => @connection['tenant_id'].to_s
    }
    HTTParty.post(url, body: payload.to_json, headers: headers)
  end

  def put(endpoint, payload = {})
    url = "https://#{@connection['domain']}.simnang.com/api/public/api/1/#{endpoint}"
    headers = {
      "Authorization" => "Bearer #{@connection['api_key']}",
      "Autopal-Instance-ID" => @connection['tenant_id'].to_s
    }
    HTTParty.put(url, body: payload.to_json, headers: headers)
  end

  def get(endpoint)
    url = "https://#{@connection['domain']}.simnang.com/api/public/api/1/#{endpoint}"
    headers = {
      "Authorization" => "Bearer #{@connection['api_key']}",
      "Autopal-Instance-ID" => @connection['tenant_id'].to_s
    }
    HTTParty.get(url, headers: headers)
  end

  def error(message)
    raise StandardError, message
  end

  def call(method_name, *args)
    @methods[method_name.to_sym].call(*args)
  end
  
  def self.load_connector(path)
    eval(File.read(path))
  end
end
