# Specs for UPDATE /tasks/#{id} endpoint
describe Api::V1::TasksController do
  let(:user) { create(:user, :with_tasks) }

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

  context 'valid updates' do
    before(:each) { @task = user.tasks.first }

    it 'it should update the "archived" attribute' do
      expect(@task.archived).to eq false
      put tasks_endpoint(@task.id), api_key: user.api_key, archived: true
      @task.reload
      expect(@task.archived).to eq true
    end

    it 'it should update the "completed" attribute' do
      expect(@task.completed).to eq false
      put tasks_endpoint(@task.id), api_key: user.api_key, completed: true
      @task.reload
      expect(@task.completed).to eq true
    end

    it 'it should update the "due" attribute' do
      due_date = Date.parse('Sept 10 2000')
      expect(@task.due).to eq nil
      put tasks_endpoint(@task.id), api_key: user.api_key, due: due_date
      @task.reload
      expect(@task.due).to eq due_date
    end

    it 'it should update the "schedule" attribute' do
      scheduled_date = Date.parse('Sept 15 2000')
      expect(@task.schedule).to eq nil
      put tasks_endpoint(@task.id), api_key: user.api_key, schedule: scheduled_date
      @task.reload
      expect(@task.schedule).to eq scheduled_date
    end

    it 'it should update the "title" attribute' do
      new_title = Faker::Lorem.sentence
      put tasks_endpoint(@task.id), api_key: user.api_key, title: new_title
      @task.reload
      expect(@task.title).to eq new_title
    end
  end
end
