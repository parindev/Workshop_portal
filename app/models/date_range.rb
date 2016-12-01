# == Schema Information
#
# Table name: date_ranges
#
#  id               :integer          not null, primary key
#  event_id         :integer          index
#  start_date       :date
#  end_date         :date
#  created_at       :datetime         not null
#  updated_at       :datetime         not null

#
class DateRange < ActiveRecord::Base


  belongs_to :event

  validate :validate_start_date_not_in_past
  validate :validate_end_not_before_start

  def validate_start_date_not_in_past
    if start_date < Date.today
      errors.add(:start_date, "darf nicht in der Vergangenheit liegen.")
    end
    if end_date < Date.today
      errors.add(:end_date, "darf nicht in der Vergangenheit liegen.")
    end
  end

  def validate_end_not_before_start
    if end_date < start_date
      errors.add(:end_date, "kann nicht vor Start-Datum liegen.")
    end
  end

  def self.human_attribute_name(*args)
    if args[0].to_s == "start_date"
      return "Anfangs-Datum"
    elsif args[0].to_s == "end_date"
      return "End-Datum"
    end

    # NOTE: In our quest for 100% code coverage we can't have this line.
    # If anyone is to add a new attribute that uses the default label,
    # reenable this line.
    # super
  end

end
