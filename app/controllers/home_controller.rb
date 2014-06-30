class HomeController < ApplicationController
  def index
    @countries = Country.all.sort_by(&:en_name).to_json
    @all_subkasts = Subkast.all.to_json
    @my_subkasts = Subkast.in(code: current_user.my_subkasts).to_json
  end
end
