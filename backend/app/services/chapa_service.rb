require 'net/http'
require 'json'
class ChapaService
  

  CHAPA_SECRET_KEY = "CHASECK_TEST-wQFyGEkNUSjBxj5IQ31mx0aZ3F9ZbMGy"

  def self.initialize_payment(payment_data)
    uri = URI("https://api.chapa.co/v1/transaction/initialize")
    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{CHAPA_SECRET_KEY}"
    }
    Rails.logger.info "sending payment to chapa"
    Rails.logger.info "Headers: #{headers}"
    Rails.logger.info "Body: #{payment_data.to_json}"

    request = Net::HTTP::Post.new(uri, headers)
    request.body = payment_data.to_json

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    JSON.parse(response.body)
  rescue => e
    Rails.logger.error("Chapa initialization failed: #{e.message}")
    {}
  end

  def self.verify_payment(tx_ref)
    uri = URI("https://api.chapa.co/v1/transaction/verify/#{tx_ref}")
    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Bearer #{CHAPA_SECRET_KEY}"

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    JSON.parse(response.body)
  rescue => e
    Rails.logger.error("Chapa verification failed: #{e.message}")
    {}
  end
end