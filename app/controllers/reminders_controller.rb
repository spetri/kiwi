class RemindersController < ApplicationController
  def index
    @reminders = Reminder.where(user_id: params[:user_id], event_id: params[:event_id])
  end

  def create
    @reminder = Reminder.new(reminder_params)

    if @reminder.save
      pp @reminder
      render 'show'
    end
  end

  def destroy
    @reminder = Reminder.find(params[:id]).destroy
    render nothing: true
  end
  private

  def reminder_params
    params.permit(:user_id, :event_id, :time_to_event, :recipient_time_zone)
  end
end
