FactoryGirl.define do
  factory :step do
    title { Faker::Lorem.sentence }
    task { create(:task) }
  end
end
