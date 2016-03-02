User.create!(name:  "Daenerys Targaryen",
             email: "stormborn@khaleesi.com",
             password:              "foobar",
             password_confirmation: "foobar",
             admin: true)

User.create!(name:  "Jon Snow",
             email: "lord_commander@nightswatch.org",
             password:              "foobar",
             password_confirmation: "foobar")

User.create!(name:  "Arya Stark",
             email: "waterdancer@braavos.gov",
             password:              "foobar",
             password_confirmation: "foobar")

User.create!(name:  "Ned Stark",
             email: "winteriscoming@winterfell.gov",
             password:              "foobar",
             password_confirmation: "foobar")

99.times do |n|
  name  = Faker::Name.name
  email = "facelessman-#{n+1}@halloffaces.com"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password)
end

users = User.order(:created_at).take(6)
50.times do
  name = Faker::Lorem.sentence(1)[0...15]
  users.each { |user| user.jobs.create!(name: name) }
end
