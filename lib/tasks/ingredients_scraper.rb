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
    File.open("../../db/vegetables.json", 'wb') do |file|
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
    File.open("../../db/fruits.json", 'wb') do |file|
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
    File.open("../../db/herbes_aromates.json", 'wb') do |file|
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
    File.open("../../db/condiments.json", 'wb') do |file|
     file.write(JSON.generate(seasoning))
    end
  end

  scraper = Scraper.new
  scraper.scrap_seasoning
end
