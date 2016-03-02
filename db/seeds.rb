User.create!(name:  "Daenerys Targaryen",
             email: "stormborn@khaleesi.com",
             password:              "foobar",
             password_confirmation: "foobar",
             admin: true)

User.create!(name:  "Jon Snow",
             email: "lord_commander@nightswatch.org",
             password:              "foobar",
             password_confirmation: "foobar")

User.create!(name:  "Ned Stark",
             email: "winteriscoming@winterfell.gov",
             password:              "foobar",
             password_confirmation: "foobar")

User.create!(name:  "Hodor",
             email: "hodor@hodor.hodor",
             password:              "hodorhodor",
             password_confirmation: "hodorhodor")

99.times do |n|
  name  = Faker::Name.name
  email = "facelessman-#{n+1}@halloffaces.com"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password)
end
