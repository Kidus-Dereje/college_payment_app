require 'jwt'
class JwtService
  SECRET_KEY =' [927e4ab88a5790094a82c4fe1015ebcf6687da8b83f69d5a3db08e75995ffb9ed6dc6f6c2b18133d62e348ae426e885a97c161331746f0c92d5a65c74eec0b15]'
  
  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY)
  end
  def self.decode(token)
    body= JWT.decode(token, SECRET_KEY)[0]
  rescue JWT::DecodeError
    nil
  end
end