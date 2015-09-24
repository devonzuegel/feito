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
  end

  def self.included(receiver)
    receiver.extend ClassMethods
    receiver.send :include, InstanceMethods
  end
end
