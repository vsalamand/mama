class ChecklistsController < ApplicationController
  before_action :authenticate_admin!

  def index
    @checklists = Checklist.all
  end

  def show
    @checklist = Checklist.find(params[:id])
    @checklist.checklist_items.build
  end

  def new
    @checklist = Checklist.new
  end

  def create
    @checklist = Checklist.new(checklist_params)
    if @checklist.save
      redirect_to checklist_path(@checklist)
    else
      redirect_to new_checklist_path
    end
  end

  def edit
    @checklist = Checklist.find(params[:id])
  end

  def update
    @checklist = Checklist.find(params[:id])
    @checklist.update(checklist_params)
    redirect_to checklist_path(@checklist)
  end


  private
  def checklist_params
    params.require(:checklist).permit(:name, :schedule, :diet_id, list_ids: [])
  end
end
