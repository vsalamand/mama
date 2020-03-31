class ChecklistItemsController < ApplicationController
  before_action :set_checklist, only: [ :new, :create, :edit, :update ]
  before_action :set_checklist_item, only: [ :edit, :update ]
  before_action :authenticate_admin!

  def new
    @checklist_item = ChecklistItem.new
  end

  def create
    @checklist_item = ChecklistItem.new(checklist_item_params)
    @checklist_item.checklist = @checklist
    if @checklist_item.save
      redirect_to checklist_path(@checklist)
    else
      render 'new'
    end
  end

  def edit
  end

  def update
    @checklist_item.update(checklist_item_params)
    redirect_to checklist_path(@checklist)
  end

  private
  def set_checklist
    @checklist = Checklist.find(params[:checklist_id])
  end

  def set_checklist_item
    @checklist_item = ChecklistItem.find(params[:id])
  end

  def checklist_item_params
    params.require(:checklist_item).permit(:checklist_id, :list_id, :name) ## Rails 4 strong params usage
  end
end
