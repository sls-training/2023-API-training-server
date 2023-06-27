# frozen_string_literal: true

class Item < ApplicationRecord
  belongs_to :user
  has_one_attached :file

  validates :name, presence: true, length: { maximum: 128 }, uniqueness: { scope: :user_id }
  validates :description, length: { maximum: 1024 }
  validates :file, attached: true, size: { less_than_or_equal_to: 1.megabytes }

  # TODO: コールバック以外に適切な方法があるかもしれない。
  before_validation :set_fallback_filename, if: -> { name.blank? }

  private

  def set_fallback_filename
    self.name = file&.filename
  end
end
