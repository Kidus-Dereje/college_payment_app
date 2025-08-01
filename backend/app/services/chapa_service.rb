# app/services/chapa_service.rb

class ChapaService
  require 'net/http'
  require 'json'

  CHAPA_SECRET_KEY = "CHASECK_TEST-wQFyGEkNUSjBxj5IQ31mx0aZ3F9ZbMGy"

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