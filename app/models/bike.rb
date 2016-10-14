class Bike < ApplicationRecord
  validates_presence_of :bike_index_id
  validates_uniqueness_of :bike_index_id

  has_and_belongs_to_many :serial_searches, -> { distinct }

  def update_was_stolen
    if stolen == true
      self.was_stolen = true
    end
  end

  def self.find_or_create_bikes_from_bike_array(bike_array)
    bike_array.each do |bike_attributes|
      bike = Bike.first_or_create(bike_attributes.except(:serial_search_id))
      bike.update_was_stolen
      serial_search = SerialSearch.find(bike_attributes[:serial_search_id])
      bike.serial_searches << serial_search
    end
  end
end
