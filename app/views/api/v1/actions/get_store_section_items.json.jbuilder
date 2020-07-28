require 'open-uri'

json.stores  Store.all.each do |store|
    json.store_id store.id
    json.store_name store.name
    json.top_sections store.store_section_items.where(level:0).each do |section|
      json.id section.id
      json.name section.name
      json.sections section.children.each do |section|
        json.id section.id
        json.name section.name
        json.sub_sections section.children.each do |section|
          json.id section.id
          json.name section.name
          json.breadcrumb section.breadcrumb
        end
      end
    end
  end

