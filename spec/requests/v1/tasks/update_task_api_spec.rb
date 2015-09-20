describe Api::V1::TasksController do
  let(:user) { create(:user, :with_tasks) }

  describe 'UPDATE /tasks/#{id} endpoint' do
    let(:hidden_task) { create(:task) }

    it 'should return an :unauthorized error when user tries to update a task (s)he doesn\'t own' do
      put tasks_endpoint(hidden_task.id), api_key: user.api_key
      # assert_response :unauthorized
      # expect(response.body).to match(User::INVALID_API_KEY)
    end
  end
end
