class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]

  def index
    @users = User.all.order(created_at: :desc)
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    assign_role(@user)

    if @user.errors.none? && @user.save
      redirect_to admin_user_path(@user), notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @user.assign_attributes(user_params)
    assign_role(@user)

    if @user.errors.none? && @user.save
      redirect_to admin_user_path(@user), notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == Current.user
      redirect_to admin_users_path, alert: t(".cannot_delete_self")
    else
      @user.destroy
      redirect_to admin_users_path, notice: t(".success")
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  def assign_role(user)
    return unless role_param
    return user.role = role_param if User.roles.key?(role_param)

    user.errors.add(:role, :inclusion, value: role_param)
  end

  def role_param
    params.require(:user)[:role].presence
  end
end
