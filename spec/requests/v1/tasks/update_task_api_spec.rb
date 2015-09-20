describe Api::V1::TasksController do
  let(:user) { create(:user, :with_tasks) }

  describe 'UPDATE /tasks/#{id} endpoint' do
    context 'unauthorized actions' do
      let(:hidden_task) { create(:task) }

      it 'should return :unauthorized when user tries to update task (s)he doesn\'t own' do
        expect(hidden_task.user).to_not eq user
        expect(hidden_task.belongs_to?(user)).to be false
        put tasks_endpoint(hidden_task.id), api_key: user.api_key
        assert_response :unauthorized
        expect(response.body).to match(User::INVALID_API_KEY)
      end

      it 'should return a 404 when user tries to update a task that doesn\'t exist' do
        put tasks_endpoint(1_000_000), api_key: user.api_key
        assert_response :not_found
      end
    end
  end

  it 'it should update the "archived" attribute'
  it 'it should update the "completed" attribute'
  it 'it should update the "due" attribute'
  it 'it should update the "schedule" attribute'
  it 'it should update the "title" attribute'
end
