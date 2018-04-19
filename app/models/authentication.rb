# no use now
class Authentication < ApplicationRecord
  belongs_to :user

  validates :provider, presence: true, uniqueness: { scope: :user_id }
  validates :uid, presence: true, uniqueness: { scope: :provider }
end
