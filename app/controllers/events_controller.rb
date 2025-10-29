class EventsController < ApplicationController
  def index
    @events = Event.all

    case params[:sort]
    when "alphabetical"
      @events = @events.order(:title)
    when "date"
      @events = @events.order(:date)
    when "date-desc"
      @events = @events.order(date: :desc)
    else
      @events = @events.order(:created_at)
    end
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
