class Subkast
  include Mongoid::Document

  field :name, type: String
  field :code, type: String
  field :url, type: String
end
