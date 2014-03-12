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
  field :local_date, type: Date
  field :date, type: Date
  field :description, type: String
  field :upvote_names, type: Array
  field :upvote_count, type: Integer
  field :country, type: String
  field :location_type, type: String
  field :subkast, type: String
  has_many :reminders

  has_mongoid_attached_file :image, :styles =>
    {
      :thumb => "80x60^",
      :medium => "400x300^"
    },
    :processors => [:cropper]

  before_save do |event|
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

  def self.get_starting_events(datetime, zone_offset, country, subkasts, minimum, eventsPerDay, topRanked)
    listEvents = self.get_enough_events_from_day(datetime, zone_offset, country, subkasts, minimum, eventsPerDay)
    topEvents = self.top_ranked(topRanked, datetime, datetime + 7.days, zone_offset, country, subkasts)
    events = listEvents.concat topEvents
    events.uniq!
    events.sort_by! { |event| - (event.upvote_names.nil? ? 0 : event.upvote_names.size) }
    return events
  end

  def self.get_events_after_date(datetime, zone_offset, country, subkasts, howMany=0)
    self.get_enough_events_from_day(datetime, zone_offset, country, subkasts, howMany, 3)
  end

  def self.get_enough_events_from_day(datetime, zone_offset, country, subkasts, minimum, eventsPerDay)
    events = []
    lookupDatetime = datetime
    lastDate = self.get_last_date

    while events.size < minimum && ( not lookupDatetime.to_date > lastDate) do

      events.concat self.get_events_by_date(lookupDatetime, zone_offset, country, subkasts, eventsPerDay)
      lookupDatetime = lookupDatetime.next_day

    end

    events
  end

  def self.get_events_by_date(startDatetime, zone_offset, country, subkasts, howMany=0, skip=0)
    endDatetime = startDatetime + 1.day - 1.second
    self.get_events_by_range(startDatetime, endDatetime, zone_offset, country, subkasts, howMany, skip)
  end

  def self.count_events_by_date(datetime, zone_offset, country, subkasts)
    Array(self.get_events_by_date(datetime, zone_offset, country, subkasts)).size
  end

  def self.top_ranked(howMany, startDatetime, endDatetime, zone_offset, country, subkasts)
    self.get_events_by_range(startDatetime, endDatetime, zone_offset, country, subkasts, howMany)
  end

  def self.get_events_by_range(startDatetime, endDatetime, zone_offset, country, subkasts, howMany=0, skip=0)
    startDate = (startDatetime - zone_offset.minutes).beginning_of_day
    endDate = (endDatetime - zone_offset.minutes).beginning_of_day

    map = %Q[
      function () {
        if (this.location_type == 'international' || ( this.location_type == 'national' && this.country == '#{country}'))
          emit(this._id, this);
      }
    ]

    reduce = %Q[
      function (key, values) {
        return values;
      }
    ]

    eventQuery = {
      "subkast" => { "$in" => subkasts },
      "$or" => [
        { "location_type" => 'international' },
        { "location_type" => 'national', country => country }
      ],
      "$or" => [
        { "is_all_day" => false, "datetime" => { "$gte" => startDatetime.to_s, "$lte" => endDatetime.to_s } },
        { "is_all_day" => true, "local_date" => { "$gte" => startDate.to_s, "$lte" => endDate.to_s } }
      ]
    }

    done = self.any_of({ is_all_day: false, datetime: (startDatetime..endDatetime) }, {is_all_day: false, time_format: 'recurring', local_date: (startDate..endDate)}, { is_all_day: true, local_date: (startDate..endDate) }).any_in({subkast: subkasts }).map_reduce(map, reduce).out(inline: 1)
    events = done.find.to_a.map { |kv| Event.new(kv["value"]) }

    sortedEvents = events.sort_by { |event| - (event.upvote_count.nil? ? 0 : event.upvote_count) }
    howMany = sortedEvents.size if howMany == 0
    return sortedEvents.slice(skip, howMany)
  end

  def self.get_last_date
    self.order_by([:local_date, :desc])[0].local_date
  end
end
