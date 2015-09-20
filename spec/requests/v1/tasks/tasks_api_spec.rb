describe Api::V1::TasksController do
  let(:user) { create(:user, :with_tasks) }

  describe '/tasks endpoint' do
    it 'should return an :unauthorized error provided a bad API key' do
      get tasks_endpoint, api_key: 'BAD API KEY'
      assert_response :unauthorized
      expect(response.body).to match(User::INVALID_API_KEY)
    end

    it 'should return all tasks provided a valid API key' do
      get tasks_endpoint, api_key: user.api_key
      assert_response :ok
      expect(ids(response)).to match_array(ids(user.tasks))
    end
  end
end
