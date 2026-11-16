# frozen_string_literal: true

require "openssl"
require "base64"

class AesEncryptDecrypt
  KEY = Rails.application.credentials.aes_128_ecb_key
  ALGORITHM = "AES-128-ECB"

  def self.encryption(msg)
    cipher = OpenSSL::Cipher.new(ALGORITHM)
    cipher.encrypt
    cipher.key = KEY
    crypt = cipher.update(msg) + cipher.final
    Base64.encode64(crypt)
  rescue Exception => exc
    puts("Message for the encryption log file for message #{msg} = #{exc.message}")
  end

  def self.decryption(msg)
    cipher = OpenSSL::Cipher.new(ALGORITHM)
    cipher.decrypt
    cipher.key = KEY
    tempkey = Base64.decode64(msg)
    crypt = cipher.update(tempkey)
    crypt << cipher.final
    crypt
  rescue Exception => exc
    puts("Message for the decryption log file for message #{msg} = #{exc.message}")
  end
end
