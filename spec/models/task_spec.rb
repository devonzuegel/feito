require 'rails_helper'

RSpec.describe Task, type: :model do
  describe 'basic task' do
    it 'should be valid' do
      expect(build(:task)).to be_valid
    end

    it 'must have a non-blank title' do
      expect(build(:task, title: '   ')).to_not be_valid
    end
  end

  describe 'default_scope' do
    before(:all) do
      @old_task = create(:task, created_at: 5.days.ago)
      @new_task = create(:task, created_at: 2.days.ago)
    end

    it 'is in reverse-chronological created_at order' do
      default_scope_order   = Task.all
      reverse_chronological = Task.order(created_at: :desc)
      chronological         = Task.order(created_at: :asc)
      expect(default_scope_order).to match_array reverse_chronological
      expect(default_scope_order).to match_array chronological.reverse
    end
  end
end
