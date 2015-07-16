class Circle::BlockedUser < ActiveRecord::Base
  self.table_name = "blocked_users"

  belongs_to :user
  belongs_to :blocked_user, class_name: 'User', foreign_key: 'blocked_user_id'
end