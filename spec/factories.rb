FactoryGirl.define do
  factory :user do
    name      "Mark James"
    email     "mjames@this.com"
    password  "foobar"
    password_confirmation "foobar"
  end
end
