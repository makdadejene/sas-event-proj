class UpvotesController < ApplicationController
  before_action :set_event, only: [:create]

  def create
    email = upvote_params[:email]
    username = upvote_params[:username]

    # Check rate limiting
    if Upvote.rate_limit_exceeded?(email)
      render json: { 
        error: 'Rate limit exceeded. You can only upvote 10 events per hour.' 
      }, status: :too_many_requests
      return
    end

    # Check if already upvoted
    if @event.upvoted_by?(email)
      render json: { 
        error: 'You have already upvoted this event.' 
      }, status: :unprocessable_entity
      return
    end

    @upvote = @event.upvotes.build(upvote_params)

    if @upvote.save
      render json: { 
        success: true, 
        upvote_count: @event.upvote_count,
        message: 'Successfully upvoted!' 
      }, status: :created
    else
      render json: { 
        error: @upvote.errors.full_messages.join(', ') 
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @upvote = Upvote.find_by(id: params[:id], email: params[:email])
    
    if @upvote
      @event = @upvote.event
      @upvote.destroy
      render json: { 
        success: true, 
        upvote_count: @event.upvote_count,
        message: 'Upvote removed' 
      }, status: :ok
    else
      render json: { 
        error: 'Upvote not found' 
      }, status: :not_found
    end
  end

  private

  def set_event
    @event = Event.find(params[:event_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Event not found' }, status: :not_found
  end

  def upvote_params
    params.require(:upvote).permit(:email, :username)
  end
end