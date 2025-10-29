require 'rails_helper'

RSpec.describe "Events", type: :request do
  let(:valid_attributes) {
    {
      title: "K-Pop Dance Practice",
      description: "Learn K-Pop moves!",
      date: "2025-11-10",
      time: "19:00",
      tags: "Club, Cultural"
    }
  }

  describe "GET /index" do
    it "returns a successful response" do
      get events_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /new" do
    it "renders the new event page" do
      get new_event_path
      expect(response.body).to include("Create an event")
    end
  end

  describe "POST /create" do
    it "creates a new event and redirects" do
      expect {
        post events_path, params: { event: valid_attributes }
      }.to change(Event, :count).by(1)
      follow_redirect!
      expect(response.body).to include("K-Pop Dance Practice")
    end
  end
end
