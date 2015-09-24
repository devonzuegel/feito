# feito/app/services/google_calendar.rb
class GoogleCalendar
  def initialize(user)
    @client = GoogleOauth.api_client(user)
  end

  def list
    results = @client.execute(api_method: api.calendar_list.list, parameters: {}).data['items']
    ap results
    results || []
  end

  def api
    @client.discovered_api('calendar', 'v3')
  end
end
