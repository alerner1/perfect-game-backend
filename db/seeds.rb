# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

UserGame.destroy_all
UserPlayedGame.destroy_all
Game.destroy_all
User.destroy_all
me = User.create(email: 'a@a.com', password: '1234', steam_name: 'witchesofus')
skyrim = Game.create(rawg_id: 123456)
mario = Game.create(rawg_id: 8395)
UserGame.create(user: me, game: skyrim, list: "rec")
UserGame.create(user: me, game: skyrim, list: "owned")
UserGame.create(user: me, game: skyrim, list: "wish")
UserPlayedGame.create(user: me, game: skyrim, liked: 1)
UserPlayedGame.create(user: me, game: mario, liked: -1)