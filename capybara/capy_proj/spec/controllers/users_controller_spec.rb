require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe 'GET #new' do
    it 'renders the new users template' do
      get :new
      expect(response).to render_template(:new)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'signs the user in' do
        user = User.create(username: 'Nima', password: '123456')
        post :create, params: { user:{ username: 'Nima', password: '123456' } }
        expect(session[:session_token]).to eq(user.session_token)
      end
    end
    context 'with invalid params' do
      it 'flashes errors' do
        user = User.create(username: 'Nima', password: '123456')
        post :create, params: { user: { username: 'Nima', password: 'notgoodpassword' } }
        expect(flash[:errors]).to match('username already exists')
      end
    end
  end
end
