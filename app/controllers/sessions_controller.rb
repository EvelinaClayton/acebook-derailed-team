class SessionsController < Clearance::SessionsController

  def create
    @user = authenticate(params)

    sign_in(@user) do |status|
      if status.success?
        flash[:notice] = "You have successfully logged in."
        redirect_back_or url_after_create
      else
        flash.now.alert = status.failure_message
        render template: "sessions/new", status: :unauthorized
      end
    end
  end



end