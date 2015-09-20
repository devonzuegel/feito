describe Api::V1::TasksController do
  let(:user) { create(:user, :with_tasks) }

  describe '/tasks/#{id} endpoint' do
    context 'unauthorized actions' do
      let(:hidden_task) { create(:task) }

      it 'should return :unauthorized when user accesses task (s)he doesn\'t own' do
        get tasks_endpoint(hidden_task.id), api_key: user.api_key
        assert_response :unauthorized
        expect(response.body).to match(User::INVALID_API_KEY)
      end

      it 'should return :unauthorized when user doesn\'t pass correct api key' do
        get tasks_endpoint(user.tasks.first.id), api_key: 'BAD API KEY'
        assert_response :unauthorized
        expect(response.body).to match(User::INVALID_API_KEY)
      end

      it 'should return 404 when user accesses task that doesn\'t exist' do
        get tasks_endpoint(1_000_000), api_key: user.api_key
        assert_response :not_found
      end
    end

    it 'should return the requested task' do
      task = user.tasks.first
      get tasks_endpoint(task.id), api_key: user.api_key
      assert_response :ok
      expect(parsed(response)[:id]).to eq task.id
    end
  end
end
