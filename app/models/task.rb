# app/models/task.rb
class Task < ActiveRecord::Base
  # RELATIONSHIPS #
  belongs_to :user

  # VALIDATIONS #
  validates :title, presence: true, allow_blank: false

  # SCOPES #
  default_scope { order(created_at: :desc) }
end
