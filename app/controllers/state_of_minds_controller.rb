class StateOfMindsController < ApplicationController
  def index
    @entries = Current.user.state_of_minds.order(recorded_at: :desc)
  end

  def new
    @state_of_mind = Current.user.state_of_minds.build
  end

  def create
    @state_of_mind = Current.user.state_of_minds.build(state_of_mind_params)
    if @state_of_mind.save
      redirect_to state_of_minds_path, notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def state_of_mind_params
    params.require(:state_of_mind).permit(:mood_score, :entry_type, :note, :recorded_at, emotions: [], contexts: [])
  end
end
