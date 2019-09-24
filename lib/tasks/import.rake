namespace :import do
  desc "Import new product data from Leclerc catalog CSV"
  task catalog: :environment do
    #catalog = CSV.read('../../db/product_catalogs/leclerc_catalog.csv', headers:true)
    CSV.foreach('../../db/product_catalogs/leclerc_catalog.csv', headers: true) do |row|
      #Prospect.create(row.to_h)
      # numbers.each do |row|
      #   puts "#{row['Name']} - #{row['Phone']}"
      # end
    end
  end
end
