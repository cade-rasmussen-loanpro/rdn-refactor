module LoanProApiClient
  def self.request(context, method:, endpoint:, payload: nil, params: nil)
    url = params ? "#{endpoint}?#{URI.encode_www_form(params)}" : endpoint

    response = case method.to_s.downcase
               when 'get'    then context.send(:get, url)
               when 'post'   then context.send(:post, url, payload)
               when 'put'    then context.send(:put, url, payload)
               else
                 raise "Unsupported method: #{method}"
               end
    response
  rescue => e
    context.send(:error, "#{method.upcase} #{url} failed: #{e.message}")
  end
end