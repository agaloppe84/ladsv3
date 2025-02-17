class Event < ApplicationRecord
  validates :start_date, presence: { message: "La date de début est obligatoire" }
  validate :end_date_after_start_date

  private

  def end_date_after_start_date
    return if start_date.blank? || end_date.blank?

    if end_date < start_date
      errors.add(:end_date, "doit être postérieure à la date de début")
    end
  end
end
