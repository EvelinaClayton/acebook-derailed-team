require 'rails_helper'

RSpec.describe CommentsController, type: :controller do
  let(:post1) { FactoryBot.create(:post) }

  before(:each) do
    sign_in
  end
  describe 'POST /' do
    it 'returns 302 for redirection' do
      post :create, params: { comment: { body: 'hello' }, post_id: post1.id }
      expect(response).to have_http_status(302)
    end
    it 'redirects to the post' do
      post :create, params: { comment: { body: 'hello' }, post_id: post1.id }
      expect(response).to redirect_to(post_path(post1))
    end
  end
end
