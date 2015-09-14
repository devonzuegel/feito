FactoryGirl.define do
  factory :task do
    title { Faker::Lorem.sentence }
  end

  trait :with_steps do
    after :create do |task|
      Faker::Number.between(2, 8).times { create(:step, task: task) }
    end
  end
end
