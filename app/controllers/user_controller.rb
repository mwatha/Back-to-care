class UserController < ApplicationController
  def login
    if request.post?
      @user=User.new(params[:user])                                             
      logged_in_user=@user.try_to_login                                         
      if logged_in_user                                                         
        reset_session                                                           
        session[:user_id] = logged_in_user.user_id                              
        session[:ip_address] = request.env['REMOTE_ADDR']                       
        session[:location_id] = nil                                             
        redirect_to("/")                                                      
      else                                                                      
        flash[:error] = "Invalid username or password"                          
      end
    end
  end

  def logout
    flash[:notice] = 'You have been logout'
    reset_session                                                               
    redirect_to(:action => "login")
  end
end
