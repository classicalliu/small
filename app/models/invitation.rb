class Invitation < ApplicationRecord
  attr_accessor :password

  VALID_TIME_INTERVAL = 240.hours

  validates :code, :valid_before, :email, :name, presence: true
  validates_uniqueness_of :code

  belongs_to :author, class_name: 'Author', foreign_key: 'author_id', optional: true

  before_validation :init
  after_commit :send_mail, on: :create

  def active
    return unless available?
    ActiveRecord::Base.transaction do
      author = Author.create!(name: self.name, email: self.email, password: self.password)
      self.update!(author_id: author.id, used: true) if author.valid?
      self
    end
  end

  def available?
    unused? && unexpired?
  end

  def ready?
    if self.password.present?
      true
    else
      errors.add :password, I18n.t('activerecord.errors.models.invitation.no_password') if self.password.blank?
      false
    end
  end

  private

  def unused?
    !used
  end

  def unexpired?
    Time.current < self.valid_before
  end

  def init
    set_code if self.code.blank?
    set_valid_before if self.valid_before.blank?
  end

  def set_code
    begin
      self.code = SecureRandom.hex
    end while Invitation.where(code: self.code).any?
  end

  def set_valid_before
    self.valid_before = Time.current + VALID_TIME_INTERVAL
  end

  def send_mail
    # Disable email sending temporary
    InvitationMailer.invite_email(self).deliver_later
  end
end
