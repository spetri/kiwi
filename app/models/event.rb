require 'open-uri'
require 'active_support/core_ext'

class Event
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Paperclip

  field :details, type: String
  field :name, type: String
  field :user, type: String
  field :datetime, type: DateTime
  field :date, type: Date
  field :width, type: Integer
  field :height, type: Integer
  field :crop_x, type: Integer
  field :crop_y, type: Integer
  field :url, type: String
  field :is_all_day, type: Boolean
  field :time_format, type: String
  field :tv_time , type: String
  field :creation_timezone, type: String
  field :local_time, type: String
  field :description, type: String
  field :upvote_names, type: Array
  field :upvote_count, type: Integer
  field :country, type: String
  field :location_type, type: String
  has_many :reminders

  has_mongoid_attached_file :image, :styles =>
    {
      :thumb => "80x60^",
      :medium => "400x300^"
    },
    :processors => [:cropper]

  before_save do |event|
    if not event.datetime.nil?
      event.date = event.datetime.to_date
    end
    if not event.upvote_names.nil?
      event.upvote_count = event.upvote_names.size
    end
  end

  def image_from_url(url)
    if url
      self.image = open(url)
    else
      self.image = self.no_image()
    end
  end

  def update_image_from_url(url)
    if url != self.image.url(:original)
      self.image_from_url(url)
    else
      self.image.reprocess!
    end
  end
      

  def no_image
    File.open("#{Rails.root}/public/images/thumb/missing.png")
  end

  def add_upvote(username)
    if self.upvote_names.nil?
      self.upvote_names = Array.new
    end
    if ! self.upvote_names.include? username
      self.upvote_names.push username
    end
  end

  def remove_upvote(username)
    if not self.upvote_names.nil?
      self.upvote_names.delete username
    end
  end

  def how_many_upvotes
    if self.upvote_names.nil?
      return 0
    else
      self.upvote_names.length
    end
  end

  def have_i_upvoted(username)
    if self.upvote_names.nil?
      return false
    else
      self.upvote_names.include? username
    end
  end

  def self.get_events_by_date(startDatetime, howMany=0, skip=0)
    endDatetime = startDatetime + 1.day
    self.all.order_by([:upvote_count, :desc], [:datetime, :asc]).where( :$or => [
      {datetime: (startDatetime..endDatetime)}, 
      {is_all_day: true, datetime: startDatetime.beginning_of_day}
    ]
    ).skip(skip).limit(howMany)
  end

  def self.top_ranked(howMany, startDatetime, endDatetime)
    self.all.where({datetime: (startDatetime..endDatetime) }).order_by([:upvote_count, :desc]).limit(howMany)
  end

  def self.get_events_after_date(datetime, howMany=0)
    self.get_enough_events_from_day(datetime, howMany, 3)
  end

  def self.get_enough_events_from_day(datetime, minimum, eventsPerDay)
    events = []
    eventCount = 0
    lookupDatetime = datetime
    lastDate = self.get_last_date

    while eventCount < minimum && ( not lookupDatetime.to_date === lastDate.next_day.to_date ) do
      eventsOnDay = self.get_events_by_date(lookupDatetime, eventsPerDay)

      if Array(eventsOnDay).size > 0
        events.concat eventsOnDay
        eventCount += Array(eventsOnDay).size
      end

      lookupDatetime = lookupDatetime.next_day
    end

    events
  end

  def self.count_events_by_date(datetime)
    endDatetime = datetime + 1.day
    self.all.where({datetime: (datetime..endDatetime)}).size
  end

  def self.get_starting_events(datetime, minimum, eventsPerDay, topRanked)
    listEvents = self.get_enough_events_from_day(datetime, minimum, eventsPerDay)
    topEvents = self.top_ranked(topRanked, datetime, datetime + 7.days)
    events = listEvents.concat topEvents
    events.uniq!
    events.sort_by! { |event| - (event.upvote_names.nil? ? 0 : event.upvote_names.size) }
    return events
  end

  def self.get_last_date
    self.order_by([:date, :desc])[0].date
  end
end
