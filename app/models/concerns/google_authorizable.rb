# app/models/concerns/google_authorizable.rb
module GoogleAuthorizable
  extend ActiveSupport::Concern

  included do
    # validates :api_key, uniqueness: true, presence: true
    # before_validation :initial_api_key, on: :create
  end

  # Class methods
  module ClassMethods
  end

  # Instance methods
  module InstanceMethods
    def update_access(response)
      fail 'MissingGoogleAccessToken' if response['access_token'].nil?
      update_attributes(
        access_token:  response.fetch('access_token'),
        expires_at:    response.fetch('expires_in').seconds.from_now,
        refresh_token: refresh_token || response['refresh_token']
      )
    end

    def revoke_access
      update_attributes(
        access_token:  nil,
        expires_at:    nil,
        refresh_token: nil
      )
    end
  end

  def self.included(receiver)
    receiver.extend ClassMethods
    receiver.send :include, InstanceMethods
  end
end
