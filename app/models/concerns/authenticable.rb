# app/models/concerns/authenticable.rb
module Authenticable
  extend ActiveSupport::Concern

  included do
    validates :api_key, uniqueness: true, presence: true
    before_validation :initial_api_key, on: :create
  end

  INVALID_API_KEY = 'That is not a valid api key. Please log in '   \
                    'or sign up to retrieve your key, or resubmit ' \
                    'the request as a visitor without a token.'

  # Class methods
  module ClassMethods
    def unique_api_key?(token)
      !self.exists?(api_key: token)
    end

    def generate_api_key
      loop do
        token = SecureRandom.base64.tr('+/=', 'Qrt')
        return token if unique_api_key?(token)
      end
    end
  end

  # Instance methods
  module InstanceMethods
    def new_api_key
      update(api_key: self.class.generate_api_key)
      api_key
    end

    def initial_api_key
      new_api_key if api_key.nil?
    end
  end

  def self.included(receiver)
    receiver.extend ClassMethods
    receiver.send :include, InstanceMethods
  end
end
