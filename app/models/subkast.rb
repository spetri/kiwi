class Subkast
  include Mongoid::Document

  field :name, type: String
  field :code, type: String
  field :url, type: String

  def as_json(option={})
    {
      '_id' => _id.to_s,
      :code => code,
      :name => name,
      :url => url
    }
  end
end
