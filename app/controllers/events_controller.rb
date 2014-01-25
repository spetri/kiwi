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
    params = event_params.dup
    params.delete :have_i_upvoted

    #Picture cropping parameters need to be ready before the image is added to the model
    #because the paperclip processor will try to use them
    @event.width = event_params[:width]
    @event.height = event_params[:height]
    @event.crop_x = event_params[:crop_x]
    @event.crop_y = event_params[:crop_y]

    @event.update_attributes(params)

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
    params = event_params.dup
    have_i_upvoted = params.delete :have_i_upvoted

    @event.width = event_params[:width]
    @event.height = event_params[:height]
    @event.crop_x = event_params[:crop_x]
    @event.crop_y = event_params[:crop_y]

    if (! event_params[:image] && event_params[:url])
      @event.update_image_from_url(event_params[:url])
    end

    if ( user_signed_in? )
      if ( have_i_upvoted == "true" )
        @event.add_upvote(current_user.username)
      else
        @event.remove_upvote(current_user.username)
      end
    end
 
    @event.update_attributes(params)

    respond_to do |format|
      if @event.update(params)
        format.json { render action: 'show', status: :ok, location: @event }
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

  def startup_events
    @events = Event.get_starting_events(DateTime.now.beginning_of_day.utc, params[:howManyTopRanked].to_i, params[:howManyEventsPerDay].to_i, params[:howManyEventsMinimum].to_i)
  end

  def events_by_date
    @events = Event.get_events_by_date(DateTime.parse(params[:datetime]), params[:howManyEvents], params[:skip])
  end

  def events_after_date
    @events = Event.get_events_after_date(DateTime.parse(params[:datetime]), params[:howManyEvents])
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
                    :description,
                    :have_i_upvoted,
                    :country,
                    :location_type
                   )
    end
end
