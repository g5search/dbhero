require "rails_helper"

RSpec.describe Dbhero::DataclipsController, type: :controller do
  routes { Dbhero::Engine.routes }

  let(:current_user) { double("user", email: "foo@bar.com") }

  def disable_authentication
    allow(Dbhero).to receive(:authenticate).and_return(false)
    allow(controller).to receive(:_current_user).and_return(nil)
  end

  def authenticate_as(user, custom_auth: nil)
    allow(Dbhero).to receive(:authenticate).and_return(true)
    allow(controller).to receive(:_current_user).and_return(user)
    allow(Dbhero).to receive(:custom_user_auth_condition).and_return(custom_auth)
  end

  shared_examples "requires authentication" do |action, method: :get, action_params: {}|
    context "with no current user" do
      before do
        allow(Dbhero).to receive(:authenticate).and_return(true)
        allow(controller).to receive(:_current_user).and_return(nil)
        public_send(method, action, params: action_params)
      end

      it { expect(response).to have_http_status(:forbidden) }
    end

    context "with current user and no custom auth" do
      before do
        authenticate_as(current_user)
        public_send(method, action, params: action_params)
      end

      it { expect(response).not_to have_http_status(:forbidden) }
    end

    context "with current user and passing custom auth" do
      let(:admin) { double("admin", email: "a@b.com", admin?: true) }

      before do
        authenticate_as(admin, custom_auth: ->(u) { u.admin? })
        public_send(method, action, params: action_params)
      end

      it { expect(response).not_to have_http_status(:forbidden) }
    end

    context "with current user and failing custom auth" do
      let(:non_admin) { double("non_admin", email: "a@b.com", admin?: false) }

      before do
        authenticate_as(non_admin, custom_auth: ->(u) { u.admin? })
        public_send(method, action, params: action_params)
      end

      it { expect(response).to have_http_status(:forbidden) }
    end

    context "with authentication disabled" do
      before do
        disable_authentication
        public_send(method, action, params: action_params)
      end

      it { expect(response).not_to have_http_status(:forbidden) }
    end
  end

  describe "GET index" do
    include_examples "requires authentication", :index
  end

  describe "GET new" do
    include_examples "requires authentication", :new
  end

  describe "POST create" do
    let(:valid_params) { { dataclip: { description: "foo bar", raw_query: "select 'foo' as bar" } } }

    include_examples "requires authentication", :create, method: :post, action_params: { dataclip: { description: "foo bar", raw_query: "select 'foo' as bar" } }

    context "when authenticated" do
      before { authenticate_as(current_user) }

      it "creates the dataclip" do
        post :create, params: valid_params
        clip = Dbhero::Dataclip.find_by(description: "foo bar")
        expect(clip).not_to be_nil
        expect(clip.user).to eq("foo@bar.com")
        expect(clip.raw_query).to eq("select 'foo' as bar")
      end
    end

    context "when authentication is disabled" do
      before { disable_authentication }

      it "creates the dataclip with no user" do
        post :create, params: { dataclip: { description: "anonymous", raw_query: "select 1" } }
        clip = Dbhero::Dataclip.find_by(description: "anonymous")
        expect(clip).not_to be_nil
        expect(clip.user).to be_nil
      end
    end
  end

  describe "GET edit" do
    let(:dataclip) { create(:dataclip) }

    context "when authenticated" do
      before do
        authenticate_as(current_user)
        get :edit, params: { id: dataclip.token }
      end

      it { expect(response).to have_http_status(:ok) }
    end

    context "when unauthenticated" do
      before do
        allow(Dbhero).to receive(:authenticate).and_return(true)
        allow(controller).to receive(:_current_user).and_return(nil)
        get :edit, params: { id: dataclip.token }
      end

      it { expect(response).to have_http_status(:forbidden) }
    end
  end

  describe "PUT update" do
    let(:dataclip) { create(:dataclip, description: "foo bar", raw_query: "select 'foo' as bar") }

    context "when authenticated" do
      before { authenticate_as(current_user) }

      it "updates the dataclip" do
        put :update, params: { id: dataclip.token, dataclip: { description: "updated" } }
        expect(dataclip.reload.description).to eq("updated")
      end
    end

    context "when authentication is disabled" do
      before { disable_authentication }

      it "updates the dataclip" do
        put :update, params: { id: dataclip.token, dataclip: { description: "updated anon" } }
        expect(dataclip.reload.description).to eq("updated anon")
      end
    end

    context "with current user and failing custom auth" do
      let(:non_admin) { double("non_admin", admin?: false) }

      before { authenticate_as(non_admin, custom_auth: ->(u) { u.admin? }) }

      it "does not update the dataclip" do
        put :update, params: { id: dataclip.token, dataclip: { description: "updated" } }
        expect(dataclip.reload.description).to eq("foo bar")
      end
    end
  end
end
