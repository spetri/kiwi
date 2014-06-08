class RemindersController < ApplicationController
  def create
    @reminder = Reminder.new(reminder_params)

    if @reminder.save
      render 'show'
    end
  end

  def self.reminders_for

  end

  private

  def reminder_params
    params.permit(:user_id, :event_id, :time_to_event, :time_offset)
  end
end
