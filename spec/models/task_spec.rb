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

  describe 'belongs_to?()' do
    let(:user)       { create(:user) }
    let(:other_user) { create(:user) }

    it 'should belong to user' do
      expect(build(:task, user: user).belongs_to?(user)).to eq true
    end

    it 'should not belong to other_user' do
      expect(build(:task, user: user).belongs_to?(other_user)).to eq false
    end
  end

  describe 'toggle_completed!' do
    let(:task) { create(:task) }

    it 'should start false and after one toggle become true' do
      expect(task.completed?).to eq false
      task.toggle_completed!
      expect(task.completed?).to eq true
    end
  end

  describe 'toggle_archived!' do
    let(:task) { create(:task) }

    it 'should start false and after one toggle become true' do
      expect(task.archived?).to eq false
      task.toggle_archived!
      expect(task.archived?).to eq true
    end
  end
end
