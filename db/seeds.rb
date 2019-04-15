# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Here the use of ! in the create method is to avoid slient errors
# hence we can catch errors
User.create!(name: 'Efrain Pinto',
             email: 'efrapp@gmail.com',
             password: '123456',
             password_confirmation: '123456',
             admin: true)

99.times do |n|
  name = Faker::Name.name
  email = "example-#{n + 1}@railstutorial.org"
  password = "password"

  User.create!(name: name,
               email: email,
               password: password,
               password_confirmation: password)
end
