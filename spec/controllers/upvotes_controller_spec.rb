require 'rails_helper'

RSpec.describe UpvotesController, type: :controller do
  let(:event) { Event.create!(title: 'Test Event', description: 'Test', date: Date.today, time: '12:00', location: 'Test Location') }
  let(:valid_params) { { event_id: event.id, upvote: { email: 'test@example.com', username: 'testuser' } } }

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new upvote' do
        expect {
          post :create, params: valid_params, format: :json
        }.to change(Upvote, :count).by(1)
      end

      it 'returns success response' do
        post :create, params: valid_params, format: :json
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['success']).to be true
        expect(json['upvote_count']).to eq(1)
      end
    end

    context 'with invalid email' do
      it 'does not create upvote' do
        invalid_params = { event_id: event.id, upvote: { email: 'invalid', username: 'testuser' } }
        expect {
          post :create, params: invalid_params, format: :json
        }.not_to change(Upvote, :count)
      end

      it 'returns error message' do
        invalid_params = { event_id: event.id, upvote: { email: 'invalid', username: 'testuser' } }
        post :create, params: invalid_params, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['error']).to include('must be a valid email')
      end
    end

    context 'when already upvoted' do
      before do
        Upvote.create!(email: 'test@example.com', username: 'testuser', event: event)
      end

      it 'does not create duplicate upvote' do
        expect {
          post :create, params: valid_params, format: :json
        }.not_to change(Upvote, :count)
      end

      it 'returns error message' do
        post :create, params: valid_params, format: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['error']).to include('already upvoted')
      end
    end

    context 'when rate limit exceeded' do
      before do
        allow(Upvote).to receive(:rate_limit_exceeded?).and_return(true)
      end

      it 'does not create upvote' do
        expect {
          post :create, params: valid_params, format: :json
        }.not_to change(Upvote, :count)
      end

      it 'returns rate limit error' do
        post :create, params: valid_params, format: :json
        expect(response).to have_http_status(:too_many_requests)
        json = JSON.parse(response.body)
        expect(json['error']).to include('Rate limit exceeded')
      end
    end

    context 'with non-existent event' do
      it 'returns not found error' do
        invalid_params = { event_id: 99999, upvote: { email: 'test@example.com', username: 'testuser' } }
        post :create, params: invalid_params, format: :json
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Event not found')
      end
    end
  end

  describe 'DELETE #destroy' do
    let!(:upvote) { Upvote.create!(email: 'test@example.com', username: 'testuser', event: event) }

    context 'with valid email' do
      it 'deletes the upvote' do
        expect {
          delete :destroy, params: { id: upvote.id, email: 'test@example.com' }, format: :json
        }.to change(Upvote, :count).by(-1)
      end

      it 'returns success response' do
        delete :destroy, params: { id: upvote.id, email: 'test@example.com' }, format: :json
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json['success']).to be true
      end
    end

    context 'with wrong email' do
      it 'does not delete the upvote' do
        expect {
          delete :destroy, params: { id: upvote.id, email: 'wrong@example.com' }, format: :json
        }.not_to change(Upvote, :count)
      end

      it 'returns not found error' do
        delete :destroy, params: { id: upvote.id, email: 'wrong@example.com' }, format: :json
        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Upvote not found')
      end
    end
  end
end