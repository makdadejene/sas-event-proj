class EventsController < ApplicationController
  def index
    @events = Event.all.order(created_at: :desc)
  end

  def new
    @event = Event.new
  end

  def create
  @event = Event.new(event_params)
  if @event.save
    redirect_to events_path, notice: "Event created successfully"
  else
    render :new
  end
end

  private

  def event_params
    params.require(:event).permit(:title, :date, :time, :tags, :description, :image)
  end
end
