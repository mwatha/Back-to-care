# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  skip_before_filter :verify_authenticity_token  
  before_filter :authorize, :except => ["login","logout"]

  
  def authorize
    session[:current_action] = nil
    session[:current_controller] = nil
    unless action_name == "logout"
			session[:current_action] = action_name 
			session[:current_controller] = controller_name
      unless session[:user_id].nil?
        User.current_user = User.find(session[:user_id]) 
      end
    end
    if session[:user_id].blank?
      redirect_to(:controller => "user", :action => "login")
    end 
  end
  
  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
