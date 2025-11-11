# app/controllers/events_controller.rb
class EventsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  def index
    @events = Event.all

    # Filter by tags if any are selected
    if params[:tags].present?
      @events = @events.where("tags && ARRAY[?]::varchar[]", params[:tags])
    end

    # Sort events
    case params[:sort]
    when 'alphabetical'
      @events = @events.order(:title)
    when 'date'
      @events = @events.order(:date)
    when 'date-desc'
      @events = @events.order(date: :desc)
    else
      @events = @events.order(created_at: :desc)
    end
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    
    if @event.save
      redirect_to events_path, notice: 'Event was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @event = Event.find(params[:id])
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])
    
    if @event.update(event_params)
      redirect_to event_path(@event), notice: 'Event was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    redirect_to events_path, notice: 'Event was successfully deleted.'
  end

  private

  def event_params
  params.require(:event).permit(
    :title,
    :date,
    :start_time,
    :end_time,
    :location,
    :description,
    :image,
    tags: []
  )
end
end