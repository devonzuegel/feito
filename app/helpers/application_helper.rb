# app/helpers/application_helper.rb
module ApplicationHelper
  def title(page_title)
    app_title = 'Feito'
    content_for(:title, "#{page_title} | #{app_title}")
  end
end
