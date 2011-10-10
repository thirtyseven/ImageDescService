require 'factory_girl'

Factory.define :user do |u|
  u.email 'john.smith@dot.com'
  u.password '123456'
  u.username 'johns'
end