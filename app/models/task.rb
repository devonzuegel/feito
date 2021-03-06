# app/models/task.rb
class Task < ActiveRecord::Base
  # RELATIONSHIPS #
  belongs_to :user
  has_many :steps

  # VALIDATIONS #
  validates :title, presence: true, allow_blank: false

  # SCOPES #
  default_scope { order(created_at: :desc) }

  def belongs_to?(other_user)
    user == other_user
  end

  def toggle_completed!
    update_attributes(completed: !completed)
  end

  def toggle_archived!
    update_attributes(archived: !archived)
  end
end
