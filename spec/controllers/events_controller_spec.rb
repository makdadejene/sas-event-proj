# spec/controllers/events_controller_spec.rb
require 'rails_helper'

RSpec.describe EventsController, type: :controller do
  describe "GET #index" do
    # Use before block to ensure clean slate
    before do
      Event.destroy_all
    end
    
    let!(:event1) { Event.create!(title: "Alpha Event", date: Date.today + 3, time: "18:00", tags: "Sports") }
    let!(:event2) { Event.create!(title: "Beta Event", date: Date.today + 1, time: "19:00", tags: "Club") }
    let!(:event3) { Event.create!(title: "Charlie Event", date: Date.today + 2, time: "20:00", tags: "Social") }

    context "without sort parameter" do
      it "returns success" do
        get :index
        expect(response).to be_successful
      end

      it "assigns all events" do
        get :index
        events = assigns(:events).to_a
        expect(events.count).to eq(3)
        expect(events.map(&:id)).to match_array([event1.id, event2.id, event3.id])
      end

      it "orders by created_at by default" do
        get :index
        events = assigns(:events).to_a
        expect(events.map(&:id)).to eq([event1.id, event2.id, event3.id])
      end
    end

    context "with alphabetical sort" do
      it "sorts by title ascending" do
        get :index, params: { sort: 'alphabetical' }
        events = assigns(:events).to_a
        expect(events.map(&:title)).to eq(["Alpha Event", "Beta Event", "Charlie Event"])
      end
    end

    context "with date sort" do
      it "sorts by date ascending" do
        get :index, params: { sort: 'date' }
        events = assigns(:events).to_a
        # event2 has Date.today + 1, event3 has Date.today + 2, event1 has Date.today + 3
        expect(events.map(&:id)).to eq([event2.id, event3.id, event1.id])
      end
    end

    context "with date-desc sort" do
      it "sorts by date descending" do
        get :index, params: { sort: 'date-desc' }
        events = assigns(:events).to_a
        # event1 has Date.today + 3, event3 has Date.today + 2, event2 has Date.today + 1
        expect(events.map(&:id)).to eq([event1.id, event3.id, event2.id])
      end
    end

    context "with invalid sort parameter" do
      it "falls back to default sorting" do
        get :index, params: { sort: 'invalid' }
        events = assigns(:events).to_a
        expect(events.map(&:id)).to eq([event1.id, event2.id, event3.id])
      end
    end
  end

  describe "GET #new" do
    it "assigns a new event" do
      get :new
      expect(assigns(:event)).to be_a_new(Event)
    end

    it "renders the new template" do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      let(:valid_params) do
        { event: { title: "New Event", date: Date.today, time: "18:00", tags: "Sports" } }
      end

      it "creates a new event" do
        expect {
          post :create, params: valid_params
        }.to change(Event, :count).by(1)
      end

      it "redirects to events index" do
        post :create, params: valid_params
        expect(response).to redirect_to(events_path)
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) do
        { event: { title: "", date: nil, time: nil } }
      end

      it "does not create a new event" do
        expect {
          post :create, params: invalid_params
        }.not_to change(Event, :count)
      end

      it "renders new template" do
        post :create, params: invalid_params
        expect(response).to render_template(:new)
      end

      it "returns unprocessable entity status" do
        post :create, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with partial invalid parameters" do
      it "handles missing title" do
        post :create, params: { event: { title: "", date: Date.today, time: "18:00" } }
        expect(response).to render_template(:new)
      end

      it "handles missing date" do
        post :create, params: { event: { title: "Event", date: nil, time: "18:00" } }
        expect(response).to render_template(:new)
      end

      it "handles missing time" do
        post :create, params: { event: { title: "Event", date: Date.today, time: nil } }
        expect(response).to render_template(:new)
      end
    end
  end

  describe "GET #show" do
    let(:event) { Event.create!(title: "Test Event", date: Date.today, time: "18:00", tags: "Sports") }

    it "assigns the requested event" do
      get :show, params: { id: event.id }
      expect(assigns(:event)).to eq(event)
      expect(response).to be_successful
    end
  end

  describe "GET #edit" do
    let(:event) { Event.create!(title: "Test Event", date: Date.today, time: "18:00", tags: "Sports") }

    it "assigns the requested event" do
      get :edit, params: { id: event.id }
      expect(assigns(:event)).to eq(event)
      expect(response).to be_successful
    end
  end

  describe "PUT #update" do
    let(:event) { Event.create!(title: "Test Event", date: Date.today, time: "18:00", tags: "Sports") }

    context "with valid parameters" do
      it "updates the event" do
        put :update, params: { id: event.id, event: { title: "Updated Event" } }
        event.reload
        expect(event.title).to eq("Updated Event")
      end

      it "redirects to the event" do
        put :update, params: { id: event.id, event: { title: "Updated Event" } }
        expect(response).to redirect_to(event_path(event))
      end
    end

    context "with invalid parameters" do
      it "renders edit template" do
        put :update, params: { id: event.id, event: { title: "" } }
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:event) { Event.create!(title: "Test Event", date: Date.today, time: "18:00", tags: "Sports") }

    it "destroys the event" do
      expect {
        delete :destroy, params: { id: event.id }
      }.to change(Event, :count).by(-1)
    end

    it "redirects to events index" do
      delete :destroy, params: { id: event.id }
      expect(response).to redirect_to(events_path)
    end
  end
end