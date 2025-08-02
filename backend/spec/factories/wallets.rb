FactoryBot.define do
  factory :wallet do
    association :user
    balance { 0.0 }
  end
end