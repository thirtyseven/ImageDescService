require 'factory_girl'

Factory.define :user do |u|
  u.email 'john.smith@dot.com'
  u.password '123456'
  u.username 'johns'
end
Factory.define :dynamic_image do |i|
  i.book_uid 'tst1234'
  i.book_title 'sample book'
  i.image_location 'images/first.jpg'
end

Factory.define :dynamic_description do |desc|
  desc.body 'sample description'
  desc.submitter 'testSystem'
  desc.dynamic_image_id 1
end