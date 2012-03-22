require 'factory_girl'
require 'factory_girl/syntax/sham'

Sham.name        { "Name" }
Sham.email {|n| "somebody#{n}@example.com" }
Sham.username("FOO") { |c| "User-#{c}" }

FactoryGirl.define do

  factory :user do 
    email {Sham.email}
    username {Sham.username}
    password '123456'
    libraries { |lib|
      [ 
        Factory(:library),
        Factory(:library, {:name => 'Eureka Library'})  
      ]  
    }
  end

  factory :role do 
    name 'writer'
  end  
  
  factory :user_role do |ur|
    ur.association :user
    ur.association :role
  end
  
  factory :library do |lib|
       lib.name 'San Francisco Public Library'
  end

  factory :user_library do |u_lib|
       u_lib.association :user
       u_lib.association :library
  end

  factory :dynamic_image do |i|
    i.image_location 'images/first.jpg'
  end

  factory :dynamic_description do |desc|
    desc.body 'sample description'
    desc.submitter 'testSystem'
    desc.dynamic_image_id 1
  end

end