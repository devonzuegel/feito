# app/models/user.rb
class User < ActiveRecord::Base
  include Authenticable

  # RELATIONSHIPS #
  has_many :tasks, dependent: :destroy

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid      = auth['uid']
      user.name     = auth['info']['name'] || '' unless auth['info'].nil?
    end
  end
end
