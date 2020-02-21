class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  prepend_before_action :check_captcha, only: [:create]

  def new
    @user = User.new
  end

  def create
    if params[:sns_auth] == 'true'
      pass = Devise.friendly_token[0,20]
      params[:user][:password] = pass
      params[:user][:password_confirmation] = pass
    end
    @user = User.new(sign_up_params)
    unless @user.valid?
      flash.now[:alert] = @user.errors.full_messages
      render :new and return
    end
    session["devise.regist_data"] = {user: @user.attributes}
    session["devise.regist_data"][:user]["password"] = params[:user][:password]
    @address = @user.build_address
    render :sms_confirmation
  end

  def sms_confirmation
  end

  def sms_recieved
  end


  def create_address
    @user = User.new(session["devise.regist_data"]["user"])
    @address = Address.new(address_params)

    unless @address.valid?
      flash.now[:alert] = @address.errors.full_messages
      render :new_address and return
    end
    @user.build_address(@address.attributes)
    @user.save
    sign_in(:user, @user)
    render :tmp_register_credit_card
  end

  def tmp_register_credit_card
  end

  def complete
  end

  def edit_address
  end


  def tmp_address
  end

  def new_address
    @address = Address.new
  end

  protected

  def address_params
    params.require(:address).permit(:postal_code, :prefectures, :city, :address, :building, :phone_number)
  end

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  end

  private
  
  def check_captcha
       unless verify_recaptcha
         self.resource = resource_class.new sign_up_params
         resource.validate # Look for any other validation errors besides Recaptcha
         respond_with resource
       end
  end

end

