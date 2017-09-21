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

  scraper = Scraper.new
  scraper.scrap_vegetables
end
