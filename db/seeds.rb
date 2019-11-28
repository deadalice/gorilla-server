# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

case Rails.env
when "development"
  User.create email: 'test@example.com'
  #User.create email: 'eldar.avatov@gmail.com', encrypted_password: '$2a$11$taCALJiHs0S09Pgu.WKZ8.trzmtyEpXm5DWKoN/mdkRzEYZzNkP2e',
  #  authentication_token: 'Tfu_P5XZyCpZxkrXpNfh'
  Package.create name: 'openssl-1.0.1'
  d = Package.create name: 'openssl-dev'
  d.parts.first.files.attach(io: File.open('storage/openssl-1.0.3/guacamole-server-0.9.14.tar.gz'), filename: 'guacamole-server-0.9.14.tar.gz')
  p = Package.create name: 'openssl-1.0.3', alias: 'openssl'
  p.dependencies << d
  Product.create title: 'OpenSSL', package: Package.last, text: 'Проверим русский язык'
  Endpoint.create name: 'test', eid: '123456', user: User.first
end
