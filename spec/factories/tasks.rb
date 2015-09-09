FactoryGirl.define do
  factory :task do
    title { Faker::Lorem.sentence }
  end
end
