class ImportCatalogJob < ApplicationJob
  queue_as :default

  def perform(catalog)
    # Do something later
    StoreItem.update_catalog(catalog)
  end
end
