class EventsController < ApplicationController
  # Ensure user is logged in for these actions
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]

  # Load the event before edit/update/destroy
  before_action :set_event, only: [:edit, :update, :destroy]

  # Ensure only the author can edit/update/destroy
  before_action :authorize_user!, only: [:edit, :update, :destroy]

  def index
    @events = Event.all

    # Filter by tags
    if params[:tags].present?
      tags = Array(params[:tags])      # ensures it's always an array
      @events = @events.where("tags && ARRAY[?]::varchar[]", tags)
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
    @event.user = current_user  # assign the author

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
    # @event is already loaded by set_event
  end

  def update
    # @event is already loaded by set_event
    if @event.update(event_params)
      redirect_to event_path(@event), notice: 'Event was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event = Event.find(params[:id])
    @event.destroy
    redirect_to events_path, notice: "Event deleted successfully."
  end


  private

  # Load event for actions that need it
  def set_event
    @event = Event.find(params[:id])
  end

  # Ensure only the author can edit/update/destroy
  def authorize_user!
    redirect_to events_path, alert: "You are not authorized to edit this event" unless @event.user == current_user
  end

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
