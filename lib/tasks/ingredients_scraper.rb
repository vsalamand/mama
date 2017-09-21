require 'open-uri'
require 'nokogiri'
require 'json'

class Scraper
  def scrap_vegetables
    url = "https://fr.wikipedia.org/wiki/Liste_de_l%C3%A9gumes"
    file = open(url)
    doc = Nokogiri::HTML(file)
    vegetables = []
    doc.search('.mw-parser-output p a[title]').each do |element|
      vegetables << element.text
    end
    File.open("../../db/db_ingredients/vegetables.json", 'wb') do |file|
     file.write(JSON.generate(vegetables))
    end
  end

  def scrap_fruits
    url = "http://www.lesfruitsetlegumesfrais.com"
    file = open(url)
    doc = Nokogiri::HTML(file)
    fruits = []
    doc.search("div[class='cell'] ol li").each do |element|
      fruits << element.text.gsub("\n",'').gsub("\t",'')
    end
    File.open("../../db/db_ingredients/fruits.json", 'wb') do |file|
     file.write(JSON.generate(fruits))
    end
  end

  def scrap_herbs_aromates
    url = "https://fr.wikipedia.org/wiki/Herbes_et_aromates_de_cuisine"
    file = open(url)
    doc = Nokogiri::HTML(file)
    herbs = []
    doc.search("div[class='colonnes'] ul li a").each do |element|
      herbs << element.text
    end
    File.open("../../db/db_ingredients/herbes_aromates.json", 'wb') do |file|
     file.write(JSON.generate(herbs))
    end
  end

  def scrap_seasoning
    url = "https://fr.wikipedia.org/wiki/Cat%C3%A9gorie:Condiment"
    file = open(url)
    doc = Nokogiri::HTML(file)
    seasoning = []
    doc.search("div[class='mw-category-group'] ul li a").each do |element|
      seasoning << element.text
    end
    File.open("../../db/db_ingredients/condiments.json", 'wb') do |file|
     file.write(JSON.generate(seasoning))
    end
  end

  def scrap_spices
    url = "https://fr.wikipedia.org/wiki/Liste_d%27%C3%A9pices"
    file = open(url)
    doc = Nokogiri::HTML(file)
    spices = []
    doc.search("div[class='mw-parser-output'] ul li a").each do |element|
      spices << element.text
    end
    File.open("../../db/db_ingredients/spices.json", 'wb') do |file|
     file.write(JSON.generate(spices))
    end
  end

  def scrap_pasta
    url1 = "https://fr.wikipedia.org/wiki/Liste_des_p%C3%A2tes_courtes"
    file1 = open(url1)
    doc1 = Nokogiri::HTML(file1)
    pasta = []
    doc1.search("div[class='mw-parser-output'] ul li a").each do |element|
      pasta << element.text
    end
    url2 = "https://fr.wikipedia.org/wiki/Liste_des_p%C3%A2tes_longues"
    file2 = open(url2)
    doc2 = Nokogiri::HTML(file2)
    doc2.search("div[class='mw-parser-output'] ul li a").each do |element|
      pasta << element.text
    end
    File.open("../../db/db_ingredients/pasta.json", 'wb') do |file|
     file.write(JSON.generate(pasta))
    end
  end

  def scrap_rice
    url = "https://fr.wikipedia.org/wiki/Cat%C3%A9gorie:Vari%C3%A9t%C3%A9_de_riz"
    file = open(url)
    doc = Nokogiri::HTML(file)
    rices = []
    doc.search("div[class='mw-category'] ul li a").each do |element|
      rices << element.text
    end
    File.open("../../db/db_ingredients/rices.json", 'wb') do |file|
     file.write(JSON.generate(rices))
    end
  end

# mauvais scraper
  def scrap_bread
    url = "https://fr.wikipedia.org/wiki/Pain"
    file = open(url)
    doc = Nokogiri::HTML(file)
    breads = []
    doc.search("div[class='mw-parser-output'] ul li a").each do |element|
      breads << element.text
    end
    File.open("../../db/db_ingredients/pain.json", 'wb') do |file|
     file.write(JSON.generate(breads))
    end
  end

  def scrap_cheese
    url1 = "https://fr.wikipedia.org/wiki/Fromage_au_lait_de_vache"
    file1 = open(url1)
    doc1 = Nokogiri::HTML(file1)
    vache = []
    doc1.search("div[class='mw-parser-output'] ul li a").each do |element|
      vache << element.text
    end
    url2 = "https://fr.wikipedia.org/wiki/Fromages_au_lait_de_brebis"
    file2 = open(url2)
    doc2 = Nokogiri::HTML(file2)
    brebis = []
    doc2.search("div[class='mw-parser-output'] ul li a").each do |element|
      brebis << element.text
    end
    url3 = "https://fr.wikipedia.org/wiki/Cat%C3%A9gorie:Fromage_au_lait_de_ch%C3%A8vre"
    file3 = open(url3)
    doc3 = Nokogiri::HTML(file3)
    chevre = []
    doc3.search("div[class='mw-category-group'] ul li a").each do |element|
      chevre << element.text
    end
    File.open("../../db/db_ingredients/fromages.json", 'wb') do |file|
     file.write(JSON.generate(vache))
     file.write(JSON.generate(brebis))
     file.write(JSON.generate(chevre))
    end
  end

  def scrap_milk_products
    url = "https://fr.wikipedia.org/wiki/Produit_laitier"
    file = open(url)
    doc = Nokogiri::HTML(file)
    milk_product = []
    doc.search("div[class='mw-parser-output'] ul li a").each do |element|
      milk_product << element.text
    end
    File.open("../../db/db_ingredients/produits_laitiers.json", 'wb') do |file|
     file.write(JSON.generate(milk_product))
    end
  end

  def scrap_sea_fruits
    url = "https://fr.wikipedia.org/wiki/Cat%C3%A9gorie:Fruit_de_mer"
    file = open(url)
    doc = Nokogiri::HTML(file)
    seafruits = []
    doc.search("div[class='mw-category-group'] ul li a").each do |element|
      seafruits << element.text
    end
    File.open("../../db/db_ingredients/fruits_de_mer.json", 'wb') do |file|
     file.write(JSON.generate(seafruits))
    end
  end

# mauvais scraper
#https://fr.wikipedia.org/wiki/Cat%C3%A9gorie:Poisson_(aliment)
#https://fr.wikipedia.org/wiki/Poisson_gras
#https://fr.wikipedia.org/wiki/Poisson_blanc
  def scrap_fish
    url = "https://fr.wikipedia.org/wiki/Liste_des_poissons_des_lacs_et_rivi%C3%A8res_utilis%C3%A9s_en_cuisine"
    file = open(url)
    doc = Nokogiri::HTML(file)
    fish = []
    doc.search("div[class='mw-parser-output'] ul li a").each do |element|
      fish << element.text
    end
    File.open("../../db/db_ingredients/poissons.json", 'wb') do |file|
     file.write(JSON.generate(fish))
    end
  end

  scraper = Scraper.new
  scraper.scrap_fish
end
