class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :registrations, inverse_of: :login, as: :login, dependent: :destroy, class_name: "FidoLogin::Registration"
end
