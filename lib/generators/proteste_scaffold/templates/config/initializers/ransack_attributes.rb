module RansackableAttributes
  extend ActiveSupport::Concern

  UNRANSACKABLE_ATTRIBUTES = []
  included do
    def self.ransackable_attributes auth_object = nil
      ((column_names - self::UNRANSACKABLE_ATTRIBUTES) + _ransackers.keys) - ['created_at','updated_at']
    end
  end
end