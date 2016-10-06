class IpAddress < ApplicationRecord
  validates_presence_of :address
  validates_uniqueness_of :address

  has_many :log_lines
  has_many :serial_searches, through: :log_lines

  geocoded_by :address
  reverse_geocoded_by :latitude, :longitude, :address => :location

  after_validation :geocode, if: ->(obj) { obj.address.present? and obj.address_changed? }
  after_validation :reverse_geocode, :if => :has_coordinates


  def self.inspector_address?(address:, request_at:)
    where(address: address).each do |ip_address|
      if ip_address.started_being_inspector_at.present? && ip_address.started_being_inspector_at < request_at
        return true if ip_address.stopped_being_inspector_at.nil? || ip_address.stopped_being_inspector_at > request_at
      end
    end
    false
  end
end
