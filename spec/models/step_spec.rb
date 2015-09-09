require 'rails_helper'

RSpec.describe Step, type: :model do
  describe 'basic task' do
    it 'must belong to a parent task' do
      expect(build(:step, task: nil)).to_not be_valid
    end

    it 'must have a non-blank title' do
      expect(build(:step, title: '   ')).to_not be_valid
    end
  end

  describe 'default_scope' do
    before(:all) do
      @old_step = create(:step, created_at: 5.days.ago)
      @new_step = create(:step, created_at: 2.days.ago)
    end

    it 'is in chronological created_at order' do
      default_scope_order   = Step.all
      reverse_chronological = Step.order(created_at: :desc)
      chronological         = Step.order(created_at: :asc)
      expect(default_scope_order).to match_array reverse_chronological.reverse
      expect(default_scope_order).to match_array chronological
    end
  end
end
