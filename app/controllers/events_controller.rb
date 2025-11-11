# app/controllers/events_controller.rb
class EventsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  def index
    now = Time.current

  @events = Event.where(
    "date > ? OR (date = ? AND start_time > ?)",
    now.to_date, now.to_date, now
  )
    
    case params[:sort]
    when 'alphabetical'
      @events = @events.order(title: :asc)
    when 'date'
      @events = @events.order(date: :asc)
    when 'date-desc'
      @events = @events.order(date: :desc)
    else
      @events = @events.order(created_at: :asc)
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