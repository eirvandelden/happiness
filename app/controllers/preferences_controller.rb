class PreferencesController < ApplicationController
  def edit
    @user = Current.user
  end

  def update
    @user = Current.user

    if @user.update(preference_params)
      redirect_to edit_preferences_path, notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def preference_params
    params.require(:user).permit(:locale, :timezone, :color_scheme, :light_theme, :dark_theme)
  end
end
