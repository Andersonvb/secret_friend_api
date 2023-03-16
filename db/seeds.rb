# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

Location.create(name: 'Tech')
Location.create(name: 'Marketing')
Location.create(name: 'Soporte')

Worker.create(name: 'Solid Snake', location_id: 1)
Worker.create(name: 'Liquid Snake', location_id: 3)
Worker.create(name: 'Meryl', location_id: 2)
Worker.create(name: 'Boss', location_id: 2)
Worker.create(name: 'Big Boss', location_id: 1)
