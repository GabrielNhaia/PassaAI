class StudyEventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_study_event, only: [:update, :destroy]

  def index
    @study_events = current_user.study_events
    @study_event = StudyEvent.new
    
    respond_to do |format|
      format.html
      format.json { 
        render json: @study_events.map { |event|
          {
            id: event.id,
            title: event.title,
            start: event.start_time,
            end: event.end_time,
            description: event.description,
            tags: event.subject_list
          }
        }
      }
    end
  end

  def create
    @study_event = current_user.study_events.build(study_event_params)

    respond_to do |format|
      if @study_event.save
        format.html { redirect_to study_events_path, notice: 'Evento criado com sucesso.' }
        format.json { render json: @study_event.as_json(methods: :subject_list), status: :created }
      else
        format.html { render :index }
        format.json { render json: @study_event.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    if @study_event.update(study_event_params)
      render json: @study_event
    else
      render json: @study_event.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @study_event.destroy
    render json: { message: 'Evento excluído com sucesso' }
  end

  private

  def set_study_event
    @study_event = current_user.study_events.find(params[:id])
  end

  def study_event_params
    params.require(:study_event).permit(:title, :description, :start_time, :end_time, :subject_list)
  end
end
