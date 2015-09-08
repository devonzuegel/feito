FactoryGirl.define do
  factory :task do
    title 'MyString'
    due '2015-09-08 15:12:25'
    completed false
    archived false
    schedule '2015-09-08 15:12:25'
    user nil
  end
end
