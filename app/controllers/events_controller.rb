class EventsController < ApplicationController
  before_action :set_event, only: [:show, :edit, :update, :destroy]

  def index
    @events = Event.where(:datetime.ne => nil)
  end

  def show
  end

  def new
    @event = Event.new
  end

  def edit
  end

  def create
    @event = Event.new()

    #Picture cropping parameters need to be ready before the image is added to the model
    #because the paperclip processor will try to use them
    @event.width = event_params[:width]
    @event.height = event_params[:height]
    @event.crop_x = event_params[:crop_x]
    @event.crop_y = event_params[:crop_y]

    @event.update_attributes(event_params)

    if (! event_params[:image] && event_params[:url])
      @event.image_from_url(event_params[:url])
    end

    respond_to do |format|
      if @event.save
        format.json { render action: 'show', status: :created, location: @event }
      else
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @event.update(event_params)
        format.json { head :no_content }
      else
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @event.destroy
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event
      @event = Event.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def event_params
      #TODO: strong params definition
      params.permit(:details,
                    :user,
                    :datetime,
                    :name,
                    :image,
                    :url,
                    :width,
                    :height,
                    :crop_x,
                    :crop_y,
                    :is_all_day,
                    :time_format,
                    :tv_time,
                    :creation_timezone,
                    :local_time,
                    :description
                   )
    end
end
