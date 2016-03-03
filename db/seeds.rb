User.create!(name:  "Daenerys Targaryen",
             email: "stormborn@khaleesi.com",
             password:              "foobar",
             password_confirmation: "foobar",
             company: "City of Meereen",
             username: "mheesa",
             admin: true)

User.create!(name:  "Jon Snow",
             email: "lord_commander@nightswatch.org",
             password:              "foobar",
             password_confirmation: "foobar",
             company: "Night's Watch",
             username: "ghost")

User.create!(name:  "Arya Stark",
             email: "waterdancer@braavos.gov",
             password:              "foobar",
             password_confirmation: "foobar",
             company: "House of Black and White",
             username: "valar-dohaeris")

User.create!(name:  "Ned Stark",
             email: "winteriscoming@winterfell.gov",
             password:              "foobar",
             password_confirmation: "foobar",
             company: "House Stark",
             username: "hand")

99.times do |n|
  name  = Faker::StarWars.character
  email = "#{name.gsub(/\s+/, '')}-#{n+1}@empire.com"
  password = "password"
  company = Faker::Company.name
  username = Faker::Internet.user_name
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password,
               company:  company,
               username: username)
end

users = User.order(:created_at).take(6)
50.times do
  name = Faker::Hacker.noun[0...15]
  users.each { |user| user.jobs.create!(name: name, status: "Completed",
                                        nodes: 1, processors: 1,
                                        config: "starccm") }
end
