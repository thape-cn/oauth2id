require 'test_helper'

class AesEncryptDecryptTest < ActiveSupport::TestCase
  test 'encryption failures raise without printing the plaintext' do
    [nil, 'too-short'].each do |key|
      assert_silent do
        error = stub_const(AesEncryptDecrypt, :KEY, key) do
          assert_raises(AesEncryptDecrypt::Error) do
            AesEncryptDecrypt.encryption('{"api_key":"test-secret"}')
          end
        end
        assert_equal 'Encryption failed', error.message
        assert_nil error.cause
      end
    end
  end

  test 'decryption failures raise without printing the ciphertext' do
    assert_silent do
      error = stub_const(AesEncryptDecrypt, :KEY, '0123456789abcdef') do
        assert_raises(AesEncryptDecrypt::Error) do
          AesEncryptDecrypt.decryption(Base64.strict_encode64('invalid ciphertext'))
        end
      end
      assert_equal 'Decryption failed', error.message
      assert_nil error.cause
    end
  end
end
