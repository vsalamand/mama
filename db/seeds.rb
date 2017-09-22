# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'json'

def create_ingredient(name, tags)
  @ingredient = Ingredient.new(name: name)
  @ingredient.tag_list.add(tags, parse: true)
  @ingredient.save
end

def update_ingredient(name, tags)
  ingredient_id = Ingredient.where(name: name)[0].id
  @ingredient = Ingredient.find(ingredient_id)
  @ingredient.tag_list.add(tags, parse: true)
  @ingredient.save
end

#boeuf
filepath = 'db/db_ingredients/boeuf.json'
serialized_boeuf = File.read(filepath)
boeuf = JSON.parse(serialized_boeuf)
boeuf.each do |element|
  name = element
  tags = "viande, boeuf"
  Ingredient.exists?(name: name) ? update_ingredient(name, tags) : create_ingredient(name, tags)
end

