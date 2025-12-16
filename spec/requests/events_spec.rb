# spec/requests/events_spec.rb
require 'rails_helper'

RSpec.describe "Events", type: :request do
  let(:user) { User.create!(email: 'test@example.com', provider: 'google_oauth2', uid: '12345') }
  let(:other_user) { User.create!(email: 'other@example.com', provider: 'google_oauth2', uid: '67890') }

  describe "GET /events" do
    it "displays the events index page" do
      get events_path
      expect(response).to have_http_status(:success)
    end

    it "shows all public events" do
      event = Event.create!(title: 'Public Event', date: Date.today + 1, start_time: '18:00', location: 'Hall', user: user)
      get events_path
      expect(response.body).to include('Public Event')
    end

    it "does not show unlisted events to non-allowed users" do
      private_event = Event.create!(
        title: 'Private Event',
        date: Date.today + 1,
        start_time: '18:00',
        location: 'Secret',
        unlisted: true,
        allowed_emails: [user.email],
        user: user
      )
      get events_path
      expect(response.body).not_to include('Private Event')
    end
  end

  describe "GET /events/:id" do
    let(:event) { Event.create!(title: 'Test Event', date: Date.today + 1, start_time: '18:00', location: 'Hall', user: user) }

    it "displays event details" do
      get event_path(event)
      expect(response).to have_http_status(:success)
      expect(response.body).to include('Test Event')
    end

    it "shows event metadata" do
      get event_path(event)
      expect(response.body).to include('Hall')
    end

    context "with unlisted event" do
      let(:private_event) do
        Event.create!(
          title: 'Private Event',
          date: Date.today + 1,
          start_time: '18:00',
          location: 'Secret',
          unlisted: true,
          allowed_emails: [user.email],
          user: user
        )
      end

      it "blocks non-allowed users" do
        sign_in other_user
        get event_path(private_event)
        expect(response).to redirect_to(events_path)
      end

      it "allows creator to view" do
        sign_in user
        get event_path(private_event)
        expect(response).to have_http_status(:success)
      end

      it "allows invited users to view" do
        # Create private event with a different email in allowed list
        private_event_with_invite = Event.create!(
          title: 'Private Event',
          date: Date.today + 1,
          start_time: '18:00',
          location: 'Secret',
          unlisted: true,
          allowed_emails: ['invited@example.com'],
          user: user
        )
        invited_user = User.create!(email: 'invited@example.com', provider: 'google_oauth2', uid: '99999')
        sign_in invited_user
        get event_path(private_event_with_invite)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /events/new" do
    context "when logged in" do
      before { sign_in user }

      it "displays the new event form" do
        get new_event_path
        expect(response).to have_http_status(:success)
      end

      it "shows form fields" do
        get new_event_path
        expect(response.body).to include('Title')
        expect(response.body).to include('Date')
        expect(response.body).to include('Location')
      end
    end

    context "when not logged in" do
      it "redirects to login" do
        get new_event_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /events" do
    context "when logged in" do
      before { sign_in user }

      it "creates a new event" do
        expect {
          post events_path, params: {
            event: {
              title: 'New Event',
              date: Date.today + 1,
              start_time: '18:00',
              location: 'Test Hall'
            }
          }
        }.to change(Event, :count).by(1)
      end

      it "redirects to events index after creation" do
        post events_path, params: {
          event: {
            title: 'New Event',
            date: Date.today + 1,
            start_time: '18:00',
            location: 'Test Hall'
          }
        }
        expect(response).to redirect_to(events_path)
      end

      it "creates event with tags" do
        post events_path, params: {
          event: {
            title: 'Tagged Event',
            date: Date.today + 1,
            start_time: '18:00',
            location: 'Hall',
            tags: ['tech', 'academic']
          }
        }
        expect(Event.last.tags).to eq(['tech', 'academic'])
      end

      it "re-renders form with invalid data" do
        post events_path, params: {
          event: {
            title: '',
            date: Date.today + 1,
            start_time: '18:00',
            location: 'Hall'
          }
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when not logged in" do
      it "redirects to login" do
        post events_path, params: {
          event: {
            title: 'New Event',
            date: Date.today + 1,
            start_time: '18:00',
            location: 'Hall'
          }
        }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /events/:id/edit" do
    let(:event) { Event.create!(title: 'Test Event', date: Date.today + 1, start_time: '18:00', location: 'Hall', user: user) }

    context "when owner" do
      before { sign_in user }

      it "displays the edit form" do
        get edit_event_path(event)
        expect(response).to have_http_status(:success)
      end

      it "pre-fills form with current values" do
        get edit_event_path(event)
        expect(response.body).to include('Test Event')
      end
    end

    context "when not owner" do
      before { sign_in other_user }

      it "redirects with error" do
        get edit_event_path(event)
        expect(response).to redirect_to(events_path)
        expect(flash[:alert]).to include('not authorized')
      end
    end

    context "when not logged in" do
      it "redirects to login" do
        get edit_event_path(event)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "PATCH /events/:id" do
    let(:event) { Event.create!(title: 'Old Title', date: Date.today + 1, start_time: '18:00', location: 'Old Location', user: user) }

    context "when owner" do
      before { sign_in user }

      it "updates the event" do
        patch event_path(event), params: {
          event: { title: 'Updated Title' }
        }
        event.reload
        expect(event.title).to eq('Updated Title')
      end

      it "redirects to events index" do
        patch event_path(event), params: {
          event: { title: 'Updated Title' }
        }
        expect(response).to redirect_to(events_path)
      end

      it "re-renders form with invalid data" do
        patch event_path(event), params: {
          event: { title: '' }
        }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when not owner" do
      before { sign_in other_user }

      it "does not update event" do
        patch event_path(event), params: {
          event: { title: 'Hacked' }
        }
        event.reload
        expect(event.title).not_to eq('Hacked')
      end

      it "redirects with error" do
        patch event_path(event), params: {
          event: { title: 'Hacked' }
        }
        expect(response).to redirect_to(events_path)
      end
    end
  end

  describe "DELETE /events/:id" do
    let!(:event) { Event.create!(title: 'Test Event', date: Date.today + 1, start_time: '18:00', location: 'Hall', user: user) }

    context "when owner" do
      before { sign_in user }

      it "deletes the event" do
        expect {
          delete event_path(event)
        }.to change(Event, :count).by(-1)
      end

      it "redirects to events index" do
        delete event_path(event)
        expect(response).to redirect_to(events_path)
      end

      it "deletes associated upvotes" do
        event.upvotes.create!(email: 'voter@example.com', username: 'voter')
        expect {
          delete event_path(event)
        }.to change(Upvote, :count).by(-1)
      end
    end

    context "when not owner" do
      before { sign_in other_user }

      it "does not delete event" do
        expect {
          delete event_path(event)
        }.not_to change(Event, :count)
      end

      it "redirects with error" do
        delete event_path(event)
        expect(response).to redirect_to(events_path)
        expect(flash[:alert]).to include('not authorized')
      end
    end

    context "when not logged in" do
      it "redirects to login" do
        delete event_path(event)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "Sorting and filtering" do
    before do
      Event.destroy_all
      @event1 = Event.create!(title: 'Alpha', date: Date.today + 3, start_time: '18:00', location: 'Hall A', tags: ['tech'], user: user)
      @event2 = Event.create!(title: 'Beta', date: Date.today + 1, start_time: '18:00', location: 'Hall B', tags: ['sports'], user: user)
      @event3 = Event.create!(title: 'Gamma', date: Date.today + 5, start_time: '18:00', location: 'Hall C', tags: ['tech'], user: user)
    end

    it "sorts alphabetically" do
      get events_path, params: { sort: 'alphabetical' }
      expect(response.body.index('Alpha')).to be < response.body.index('Beta')
      expect(response.body.index('Beta')).to be < response.body.index('Gamma')
    end

    it "sorts by date ascending" do
      get events_path, params: { sort: 'date' }
      # Beta has earliest date
      expect(response.body).to include('Beta')
    end

    it "sorts by date descending" do
      get events_path, params: { sort: 'date-desc' }
      # Gamma has latest date
      expect(response.body).to include('Gamma')
    end

    it "filters by tag" do
      get events_path, params: { tags: ['tech'] }
      expect(response.body).to include('Alpha')
      expect(response.body).to include('Gamma')
      expect(response.body).not_to include('Beta')
    end

    it "sorts by upvotes" do
      3.times { |i| @event2.upvotes.create!(email: "user#{i}@example.com", username: "user#{i}") }
      get events_path, params: { sort: 'upvotes' }
      expect(response.body).to include('Beta')
    end
  end
end