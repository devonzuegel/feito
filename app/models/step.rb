# app/models/step.rb
class Step < ActiveRecord::Base
  # RELATIONSHIPS #
  belongs_to :task

  # VALIDATIONS #
  validates :task, presence: true
  validates :title, presence: true, allow_blank: false

  # SCOPES #
  default_scope { order(created_at: :asc) }
end
