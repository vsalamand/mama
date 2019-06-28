RailsAdmin.config do |config|

  config.authorize_with do |controller|
    redirect_to main_app.root_path unless current_user && current_user.admin
  end

  ### Popular gems integration

  ## == Devise ==
  # config.authenticate_with do
  #   warden.authenticate! scope: :user
  # end
  # config.current_user_method(&:current_user)

  ## == Cancan ==
  # config.authorize_with :cancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  ## == Ancestry ==
  config.model Category do
    field :id
    field :name
    field :parent_id, :enum do
      enum_method do
        :parent_enum
      end
    end
    field :rating, :enum do
      enum do
        ["good", "limit", "avoid"]
      end
    end
  end

  config.model Food do
    field :id
    field :name
    field :parent_id, :enum do
      enum_method do
        :parent_enum
      end
    end
    field :availability
    field :category
    field :measure, :enum do
      enum_method do
        :measure
      end
    end
    field :serving
    field :unit
    field :unit_per_piece
    field :tag_list
  end

end
