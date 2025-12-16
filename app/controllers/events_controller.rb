# app/controllers/events_controller.rb

class EventsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_event, only: [:show, :edit, :update, :destroy]
  before_action :authorize_view!, only: [:show]
  before_action :authorize_edit!, only: [:edit, :update, :destroy]

  def index
    @events = Event.visible_to(current_user)

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
    when 'upvotes'
      @events = @events.sorted_by_upvotes
      .group('events.id')
      .order(Arel.sql('COUNT(upvotes.id) DESC'))
    else
      @events = @events.order(:created_at)
    end
  end

  def show
    # @event is already loaded by set_event
  end

  def new
    @event = Event.new
  end

def authorize_user!
    unless @event.user_id == current_user&.id
      flash[:alert] = 'You are not authorized to edit this event'
      redirect_to events_path
    end
  end

def create
  @event = Event.new(event_params)
  @event.user = current_user
  
  if @event.save
    redirect_to events_path
  else
    render :new, status: :unprocessable_entity
  end
end

def edit

end

  def upvote
    @event = Event.find(params[:id])
    
    unless current_user
      render json: { error: 'Must be logged in' }, status: :unauthorized
      return
    end

    result = @event.toggle_upvote(current_user)
    
    render json: { 
      upvote_count: @event.upvote_count,
      upvoted: result
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Event not found' }, status: :not_found
  end

def update
  @event = Event.find(params[:id])
  
  if @event.user != current_user
    redirect_to events_path, alert: "You are not authorized to edit this event."
    return
  end

  if @event.update(event_params)
    redirect_to events_path, notice: 'Event was successfully updated.'  # CHANGED FROM event_path(@event)
  else
    render :edit, status: :unprocessable_entity
  end
end

def destroy
  @event = Event.find(params[:id])
  
  # Optional: Check if current user is the owner
  if current_user && @event.user == current_user
    @event.destroy
    redirect_to events_path, notice: 'Event was successfully deleted.'
  else
    redirect_to events_path, alert: 'You are not authorized to delete this event.'
  end
end
  private

  # Load event for actions that need it
  def set_event
    @event = Event.find(params[:id])
  end

  # Ensure the user can view the event (for unlisted events)
  def authorize_view!
    unless @event.visible_to?(current_user)
      redirect_to events_path, alert: "You are not authorized to view this event."
    end
  end

  # Ensure only the author can edit/update/destroy
  def authorize_edit!
    unless @event.user == current_user
      # CHANGE: Update message to match test expectations
      redirect_to events_path, alert: "You are not authorized to edit this event."
    end
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
      :unlisted,
      :allowed_emails,
      tags: []
    )
  end
end