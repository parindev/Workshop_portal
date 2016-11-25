# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string
#
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  before_create :set_default_role

  ROLES = %i[pupil tutor organizer admin]

  def role?(base_role)
    return false unless role

    ROLES.index(base_role) <= ROLES.index(role.to_sym)
  end

  def set_default_role
    self.role ||= :pupil
  end

  has_one :profile
  has_many :application_letters
  has_many :requests

  # Returns the number of application previously written by the user
  #
  # @param none
  # @return [Int] of number of applications
  def participation_count
    ApplicationLetter.where(:user_id => id).count()
  end

  # Returns the number of previously accepted applications from the user
  #
  # @param none
  # @return [Int] of number of accepted applications
  def accepted_application_count
    ApplicationLetter.where(:user_id => id, :status => true).count()
  end

  # Returns the number of previously rejected applications from the user
  #
  # @param none
  # @return [Int] of number of rejected applications
  def rejected_application_count
    ApplicationLetter.where(:user_id => id, :status => false).count()
  end

end
