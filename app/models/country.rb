class Country
  include Mongoid::Document
  include Mongoid::Timestamps
  field :code, type: String
  field :en_name, type: String
  field :order, type: Integer

  def as_json(option={})
    {
      '_id' => code,
      :en_name => en_name,
      :order => order
    }
  end
end
