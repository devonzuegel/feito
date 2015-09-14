FactoryGirl.define do
  factory :user do
    name 'Test User'

    trait :with_tasks do
      after :create do |user|
        2.times { create(:task, :with_steps, user: user) }
      end
    end
  end
end
