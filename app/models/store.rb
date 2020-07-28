class Store < ApplicationRecord
  belongs_to :merchant
  has_many :store_items
  has_many :products, through: :store_items
  has_many :foods, through: :products
  has_many :store_section_items

  STORE_TYPE = ["online", "physical"]


  def self.get_cheapest_store_price(list)
    # !! sometimes the last items is not taken into account because the thread to create it is not finished when method is called
    items = list.get_uncomplete_list_items_items

    cheapest_store = []
    Store.all.each do |store|
      data = store.get_cheapest_cart_price(items)
      min_price = sprintf("%.2f", data.pluck(:price).inject(0){|sum,x| sum + x })
      cheapest_store << [min_price, data.size, store]
    end

    # sort by cart price
    return cheapest_store.sort_by{|store| store.first.to_f}
  end

  def get_cheapest_cart_price(items)
    cheapest_cart_price = []

    items.each do |item|
      # for each item, get related products per store, sort by price, and return cheapest product
      cheapest_cart_price << StoreItem.get_results_sorted_by_price(item, self).first
    end

    # remove nil elements
    return cheapest_cart_price.compact
  end

  def get_level_0_store_sections
    self.store_section_items.where(level: 0)
  end


  def create_store_section_items
    # get list of level 0 store sections
    level_0 = self.store_items.pluck(:shelters).uniq.map{ |shelter| shelter.first }.uniq

    level_0.each do |shelter_0|
      # find or create level 0 store sections
      l0_store_section_item = StoreSectionItem.find_or_create_by(name: shelter_0,
                                                              # breadcrumb: breadcrumb,
                                                              store: self,
                                                              level: 0)
      # get list of level 1 store sections for the given level 0 store section
      level_1 = self.store_items.pluck(:shelters).select{ |shelter| shelter.first == shelter_0}.map{ |shelter| shelter.second }.uniq

      level_1.each do |shelter_1|
        # find or create level 1 store sections + assign level 0 ancestry
        l1_store_section_item = StoreSectionItem.find_or_create_by(name: shelter_1,
                                                              # breadcrumb: breadcrumb,
                                                              store: self,
                                                              level: 1)
        l1_store_section_item.parent_id = l0_store_section_item.id
        l1_store_section_item.save

        level_2_breadcrumbs = self.store_items.pluck(:shelters).select{ |shelter| shelter.first == shelter_0 && shelter.second == shelter_1}.uniq
        # level_2 = level_2_breadcrumbs.map{ |shelter| shelter.third }
        level_2_breadcrumbs.each do |breadcrumb|
          # find or create level 2 store sections + assign level 1 ancestry + assign breadcrumb + update related store items
          clean_breadcrumb = StoreSectionItem.clean_breadcrumb(breadcrumb)
          shelter_2 = clean_breadcrumb.third
          l2_store_section_item = StoreSectionItem.find_or_create_by(name: shelter_2,
                                                                breadcrumb: clean_breadcrumb,
                                                                store: self,
                                                                level: 2)
          l2_store_section_item.parent_id = l1_store_section_item.id
          l2_store_section_item.save
          # apply clean breadcrumb + lowest level store section item to related store items
          StoreItem.where(store: self, shelters: breadcrumb).update_all(shelters: clean_breadcrumb, store_section_item_id: l2_store_section_item.id)
        end
      end
    end
  end


  def get_main_shelter_list
    self.store_items.pluck(:shelters).uniq.map{ |array| array.first}.uniq
  end

  def get_sub_shelves(store_shelf)
    self.store_items.pluck(:shelters).uniq.select{ |shelves| shelves.include?(store_shelf)}.map{ |element| element[1..] }.uniq.split.flatten.uniq - Array(store_shelf)
  end

  def get_main_store_shelves(store_shelf)
    self.store_items.pluck(:shelters).uniq.select{ |shelves| shelves.include?(store_shelf)}.map{ |element| element.first}.uniq
  end

end
