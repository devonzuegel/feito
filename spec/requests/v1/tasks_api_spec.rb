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

  describe '/tasks/#{id} endpoint' do
    let(:hidden_task) { create(:task) }

    it 'should return an :unauthorized error when user tries to access a task (s)he doesn\'t own' do
      get tasks_endpoint(hidden_task.id), api_key: user.api_key
      assert_response :unauthorized
      expect(response.body).to match(User::INVALID_API_KEY)
    end

    it 'should return an :unauthorized error when user doesn\'t pass' do
      get tasks_endpoint(user.tasks.first.id), api_key: 'BAD API KEY'
      assert_response :unauthorized
      expect(response.body).to match(User::INVALID_API_KEY)
    end

    it 'should return a 404 when user tries to access a task that doesn\'t exist' do
      get tasks_endpoint(1000000), api_key: user.api_key
      assert_response :not_found
    end

    it 'should return the requested task' do
      task = user.tasks.first
      get tasks_endpoint(task.id), api_key: user.api_key
      assert_response :ok
      expect(parsed(response)[:id]).to eq task.id
    end
  end

  describe '/tasks/#{id}/steps endpoint', :focus do
    let(:hidden_task) { create(:task) }

    it 'should return an :unauthorized error when user tries to access a task (s)he doesn\'t own' do
      get steps_endpoint(hidden_task.id), api_key: user.api_key
      assert_response :unauthorized
      expect(response.body).to match(User::INVALID_API_KEY)
    end

    it 'should return an :unauthorized error when user doesn\'t pass' do
      get steps_endpoint(user.tasks.first.id), api_key: 'BAD API KEY'
      assert_response :unauthorized
      expect(response.body).to match(User::INVALID_API_KEY)
    end

    it 'should return a 404 when user tries to access a task that doesn\'t exist' do
      get steps_endpoint(1000000), api_key: user.api_key
      assert_response :not_found
    end

    it 'should return the requested task' do
      task = user.tasks.first
      get steps_endpoint(task.id), api_key: user.api_key

      assert_response :ok
      expected = task.steps.pluck(:id)
      actual   = parsed(response).map { |s| s[:id] }
      expect(actual).to eq expected
    end
  end
end
