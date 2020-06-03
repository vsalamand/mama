module ServiceWorkers
  class ManifestsController < ApplicationController
    skip_before_action :authenticate_user!, only: [:index]

    def index
    end
  end
end
