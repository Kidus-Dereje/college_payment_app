FactoryBot.define do
  factory :user do
    email { "user#{rand(1000)}@example.com" }
    password { "password123" } # adjust this if you're using Devise or encrypted password fields
  end
end