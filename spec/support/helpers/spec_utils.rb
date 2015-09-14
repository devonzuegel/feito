# /zen-writer/spec/support/helpers/spec_utils.rb
module SpecUtils
  # Public: Fills form at given path with provided attributes.
  #
  # hash -
  #   :name         - (String) name of the form.
  #   :attributes   - (Hash) attributes to fill and their respective values. They will
  #                   be populated according to the format "#{name}[#{attribute}]",
  #                   e.g. 'account[first_name]'.
  #   :submit_value - (String) the value of the submit button to be clicked.
  #   :signed_in    - (boolean) when `true`, signs in before filling in the form (optional).
  #
  # Examples
  #   fill_form_and_save({
  #     path:         '/settings',
  #     name:         "account",
  #     attributes:   { first_name: "James", last_name: "Smith" },
  #     submit_value: "Save"
  #   })
  #
  # Visits `/settings` and fills fields 'account[first_name]' and
  # 'account[last_name]' with 'James' and 'Smith', respectively.
  # Then, it clicks the button with the value 'Save'.
  def fill_form_and_save(hash)
    sign_in_feature if hash[:signed_in] && !signed_in?
    visit hash[:path]
    hash[:attributes].each do |key, val|
      selector = "#{hash[:name]}[#{key}]".gsub(/\[\]/, '_')
      fill_in selector, with: val
    end
    click_button hash[:submit_value]
  end

  # Public: Click an element.
  #
  # div_id - the html ID of the element you wish to click
  #
  # Examples
  #   click('id_to_click')
  #
  # Click the element with Capybara Webkit. If this fails, click with jquery to ensure
  # that the element isn't simply "covered" by a :before css element. If this also fails,
  # then alert the client.
  def click(div_id)
    page.find_by_id(div_id).click
  rescue Capybara::Webkit::ClickFailed
    page.execute_script "$('##{div_id}').click()"
  end

  # Public: Test that the current path matches the expected path
  #
  # expected_path - (String) the path that you expect to match the
  #                 current path.
  #
  # Examples
  #   path_should_be(root_path)
  #
  # Test that the current path matches the expected path.
  def path_should_be(expected_path)
    expect(current_path).to match expected_path
  end

  # Public: Sign in as a new user
  #
  # user - (User) the user you wish to sign in as. If left undefined,
  #        a new user will be created.
  #
  # Examples
  #   sign_in
  #   sign_in(existing_user)
  #
  # Returns the duplicated String.
  def sign_in(_user = nil)
    expect(session[:user_id]).to be_nil
    @user = create(:user)
    @account = @user.account
    session[:user_id] = @user.id
    expect(session[:user_id]).not_to be_nil
  end

  # Public: Creates a valid entry
  #
  # Examples
  #   create_valid_entry
  #
  # Visits root path, creates an entry entitled "MyTitle", and checks to make
  # sure we are redirected to the visitor's page.
  def create_valid_entry
    entry_data = { title: 'MyTitle', body: 'This is the body.' }
    visit root_path
    fill_in 'entry[title]', with: entry_data[:title]
    click_button 'Start writing'
    sleep 0.1
    expect(page.body).to include(entry_data[:title])
    path_should_be(%r{^\/entries\/\d+\/freewrite$})
    click_button "I'm done"
  end

  # Public: Parses a json response
  #
  # response - (String) the JSON string to be parsed
  #
  # Examples
  #   parsed("{ 'English': 'hello', 'Spanish': ['hola', 'buenos dias'] }")
  #   => {
  #        'English': 'hello',
  #        'Spanish': ['hola', 'buenos dias']
  #      }
  #
  # Parses the JSON (provided in string form) into a ruby hash.
  def parsed(response)
    return response unless response.class == ActionDispatch::TestResponse
    parsed = JSON.parse(response.body)
    if parsed.class == Array
      parsed.map(&:deep_symbolize_keys!)
    elsif parsed.class == Hash
      parsed.deep_symbolize_keys!
    end
  end

  def ids(array)
    parsed(array).map { |t| t[:id] }
  end
end
