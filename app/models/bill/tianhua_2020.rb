# frozen_string_literal: true

module Bill
  class Tianhua2020 < ApplicationRecord
    establish_connection :tianhua2020 unless Rails.env.test?
  end
end
