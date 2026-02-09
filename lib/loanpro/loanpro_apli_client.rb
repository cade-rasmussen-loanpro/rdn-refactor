module LoanProApiClient
  def self.request(context, method:, endpoint:, payload: nil)
    response = case method.to_s.downcase
               when 'get'    then context.send(:get, endpoint)
               when 'post'   then context.send(:post, endpoint, payload)
               when 'put'    then context.send(:put, endpoint, payload)
               else
                 raise "Unsupported method: #{method}"
               end
    response
  rescue => e
    context.send(:error, "#{method.upcase} #{endpoint} failed: #{e.message}")
  end
end