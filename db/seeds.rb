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

def seed_ingredient(name, tags)
  Ingredient.exists?(name: name) ? update_ingredient(name, tags) : create_ingredient(name, tags)
end

def seed(filepath, file_tags)
  serialized_ingredients = File.read(filepath)
  ingredients = JSON.parse(serialized_ingredients)
  ingredients.each do |ingredient|
    name = ingredient
    tags = file_tags
    seed_ingredient(name, tags)
  end
end

#abats
filepath = 'db/db_ingredients/abats.json'
file_tags = "abats"
seed(filepath, file_tags)
#agneau
filepath = 'db/db_ingredients/agneau.json'
file_tags = "viande, agneau"
seed(filepath, file_tags)
#boeuf
filepath = 'db/db_ingredients/boeuf.json'
file_tags = "viande, boeuf"
seed(filepath, file_tags)
#boissons
filepath = 'db/db_ingredients/boissons.json'
file_tags = ""
seed(filepath, file_tags)
#charcuterie
filepath = 'db/db_ingredients/charcuterie.json'
file_tags = "charcuterie"
seed(filepath, file_tags)
#chocolat
filepath = 'db/db_ingredients/chocolats.json'
file_tags = "chocolat"
seed(filepath, file_tags)
#condiments
filepath = 'db/db_ingredients/condiments.json'
file_tags = ""
seed(filepath, file_tags)
#confiserie
filepath = 'db/db_ingredients/confiserie.json'
file_tags = ""
seed(filepath, file_tags)
#farine
filepath = 'db/db_ingredients/farine.json'
file_tags = ""
seed(filepath, file_tags)
#farines
filepath = 'db/db_ingredients/farines.json'
file_tags = ""
seed(filepath, file_tags)
#féculents
filepath = 'db/db_ingredients/feculents.json'
file_tags = "féculents"
seed(filepath, file_tags)
#fromages
filepath = 'db/db_ingredients/fromages.json'
file_tags = "fromage"
seed(filepath, file_tags)
#fruits
filepath = 'db/db_ingredients/fruits.json'
file_tags = "fruits"
seed(filepath, file_tags)
#fruits-de-mer
filepath = 'db/db_ingredients/fruits_de_mer.json'
file_tags = "fruits de mer"
seed(filepath, file_tags)
#herbes & romates
filepath = 'db/db_ingredients/herbes_aromates.json'
file_tags = ""
seed(filepath, file_tags)
#mouton
filepath = 'db/db_ingredients/mouton.json'
file_tags = "viande, mouton"
seed(filepath, file_tags)
#oeufs
filepath = 'db/db_ingredients/oeufs.json'
file_tags = ""
seed(filepath, file_tags)
#pain
filepath = 'db/db_ingredients/pain.json'
file_tags = ""
seed(filepath, file_tags)
#pasta
filepath = 'db/db_ingredients/pasta.json'
file_tags = "pâtes"
seed(filepath, file_tags)
#poissons
filepath = 'db/db_ingredients/poissons.json'
file_tags = "poisson"
seed(filepath, file_tags)
#porc
filepath = 'db/db_ingredients/porc.json'
file_tags = "viande, porc"
seed(filepath, file_tags)
#produits laitiers
filepath = 'db/db_ingredients/produits_laitiers.json'
file_tags = ""
seed(filepath, file_tags)
#rices
filepath = 'db/db_ingredients/rices.json'
file_tags = "riz"
seed(filepath, file_tags)
#spices
filepath = 'db/db_ingredients/spices.json'
file_tags = ""
seed(filepath, file_tags)
#sucres
filepath = 'db/db_ingredients/sucres.json'
file_tags = ""
seed(filepath, file_tags)
#veau
filepath = 'db/db_ingredients/veau.json'
file_tags = "viande, veau"
seed(filepath, file_tags)
#légumes
filepath = 'db/db_ingredients/vegetables.json'
file_tags = "légumes"
seed(filepath, file_tags)
#viande
filepath = 'db/db_ingredients/viande.json'
file_tags = "viande"
seed(filepath, file_tags)
#volailles
filepath = 'db/db_ingredients/volailles.json'
file_tags = "viande, volaille"
seed(filepath, file_tags)




