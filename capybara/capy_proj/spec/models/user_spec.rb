require 'rails_helper'

RSpec.describe User, type: :model do
  let(:nima) { User.create(username: 'Nima', password: '123456')}
  # VALIDATIONS
  it { should validate_presence_of(:username) }
  # it { should validate_presence_of(:password) }
  it { should validate_presence_of(:password_digest) }
  it { should validate_presence_of(:session_token) }
  it { should validate_length_of(:password).is_at_least(6) }

  # ASSOCIATIONS
  it { should have_many(:links) }
  it { should have_many(:comments) }

  describe 'password encryption' do
    it 'does not save passwords to database' do
      User.create!(username: 'Nima', password: '123456')
      user = User.find_by(username: 'Nima')
      expect(user.password).not_to eq('123456')
    end

    it 'encrypts password using BCrypt' do
      user_params = { username: 'Nima', password: '123456' }
      expect(BCrypt::Password).to receive(:create).and_call_original
      # expect(BCrypt::Password).to receive(:create).with(
      #   user_params[:password]
      # )
      user = User.create!(user_params)
      expect(user.password_digest).to_not be_nil
    end
  end

  describe '#ensure_session_token' do
    it 'creates a session token before validation' do
      user_params = { username: 'Nima', password: '123456' }
      nima = User.create(user_params)

      expect(nima.session_token).to_not be_nil
    end
  end

  describe '#reset_session_token' do
    it 'creates a new session token' do
      user_params = { username: 'Nima', password: '123456' }
      user = User.create(user_params)
      old_token = user.session_token
      user.reset_session_token!

      expect(user.session_token).to_not eq(old_token)
    end
  end

  describe '#password=' do
    it 'sets password_digest' do
      user_params = { username: 'Nima', password: '123456' }
      user = User.create(user_params)

      expect(user.password_digest).to_not be nil
    end

    it 'verifies password is correct' do
      user_params = { username: 'Nima', password: '123456' }
      user = User.create(user_params)
      expect(user.is_password?("123456")).to be true
    end


    it 'verifies password is not correct' do
      user_params = { username: 'Nima', password: '123456' }
      user = User.create(user_params)
      expect(user.is_password?("yoooo bro")).to be false
    end
  end

  describe '#find_by_credentials' do
    it 'returns the correct user given correct credentials' do
      user_params = { username: 'Nima', password: '123456' }
      user = User.create(user_params)
      expect(User.find_by_credentials('Nima', '123456')).to eq(user)
    end

    it 'returns the correct user given incorrect credentials' do
      user_params = { username: 'Nima', password: '123456' }
      user = User.create(user_params)
      bad_params = { username: 'Nima', password: 'siiicccck' }
      expect(User.find_by_credentials('Nima', '1234562323')).to_not eq(user)
    end
  end

end
