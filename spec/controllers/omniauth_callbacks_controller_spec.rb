require 'rails_helper'

RSpec.describe Users::OmniauthCallbacksController, type: :controller do
  before do
    request.env["devise.mapping"] = Devise.mappings[:user]
  end

  describe "GET #google_oauth2" do
    let(:omniauth_auth) do
      OmniAuth::AuthHash.new({
        provider: 'google_oauth2',
        uid: '123456789',
        info: {
          email: 'test@example.com',
          name: 'Test User'
        },
        extra: {
          raw_info: { 
            name: 'Test User',
            email: 'test@example.com'
          }
        }
      })
    end

    before do
      OmniAuth.config.test_mode = true
      request.env["omniauth.auth"] = omniauth_auth
    end

    after do
      OmniAuth.config.test_mode = false
    end

    context "when user is successfully created/found" do
      it "signs in the user and redirects" do
        expect {
          get :google_oauth2
        }.to change(User, :count).by(1)

        expect(response).to redirect_to(events_path)
        expect(controller.current_user).to be_present
        expect(controller.current_user.email).to eq('test@example.com')
      end

      it "sets a flash message" do
        get :google_oauth2
        expect(flash[:notice]).to match(/Google/)
      end

      it "finds existing user instead of creating duplicate" do
        User.from_omniauth(omniauth_auth)
        
        expect {
          get :google_oauth2
        }.not_to change(User, :count)
      end
    end

    context "when user cannot be persisted" do
      before do
        allow(User).to receive(:from_omniauth).and_return(User.new)
      end

      it "redirects to registration with error" do
        get :google_oauth2
        expect(response).to redirect_to(new_user_registration_url)
        expect(flash[:alert]).to include("problem signing you in")
      end

      it "stores google data in session" do
        get :google_oauth2
        expect(session["devise.google_data"]).to be_present
        expect(session["devise.google_data"]["provider"]).to eq('google_oauth2')
      end
    end
  end
end