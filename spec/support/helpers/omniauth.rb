# /spec/support/helpers/omniauth.rb
module Omniauth
  # Mocks omniauth for testing purposes.
  module Mock
    AUTH_MOCK_HASH = {
      'provider' => 'facebook',
      'uid' => '123545',
      'info' => {
        'name'        => 'mockuser',
        'first_name'  => 'mock',
        'middle_name' => 'middlename',
        'last_name'   => 'user',
        'email'       => 'test@gmail.com',
        'image'       => 'http://graph.facebook.com/#{id}/picture'
      },
      'raw_info' => {
        'gender'      => 'female',
        'timezone'    => -7
      },
      'credentials' => {
        'token'       => 'mock_token',
        'secret'      => 'mock_secret'
      }
    }

    def auth_mock_hash
      AUTH_MOCK_HASH
    end

    def auth_mock_attrs
      { provider: auth_mock_hash['provider'], uid: auth_mock_hash['uid'].to_s }
    end

    def auth_mock
      create(:user).populate_info(auth_mock_hash) unless User.find_by(auth_mock_attrs).nil?
      OmniAuth.config.mock_auth[:facebook] = auth_mock_hash
    end

    def invalid_auth_mock
      OmniAuth.config.mock_auth[:facebook] = :invalid_credentials
    end
  end

  # Feature session helpers.
  module SessionHelpers
    def sign_in_feature
      visit root_path
      expect(page).to have_content(/sign in/i)
      auth_mock
      click_link('Sign in')
      @current_user = User.find_by(auth_mock_attrs)
    end

    def current_user
      User.find(@current_user.id) if @current_user
    end

    def current_visitor
      Visitor.find_by(user: current_user) if current_user
    end

    def signed_in?
      !visitor?
    end

    def visitor?
      current_user.nil?
    end
  end
end
