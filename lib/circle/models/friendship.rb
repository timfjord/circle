class Circle::Friendship < ActiveRecord::Base
  self.table_name = "friendships"

  STATUS_ALREADY_FRIENDS     = 1
  STATUS_ALREADY_REQUESTED   = 2
  STATUS_FRIEND_IS_YOURSELF  = 3
  STATUS_FRIENDSHIP_ACCEPTED = 4
  STATUS_FRIENDSHIP_DENIED   = 5
  STATUS_REQUESTED           = 6
  STATUS_CANNOT_SEND         = 7
  STATUS_CANNOT_ACCEPT       = 8
  STATUS_NOT_FOUND           = 9
  STATUS_BLOCKED             = 10
  STATUS_UNBLOCKED           = 11

  FRIENDSHIP_ACCEPTED = "accepted"
  FRIENDSHIP_PENDING = "pending"
  FRIENDSHIP_REQUESTED = "requested"
  FRIENDSHIP_DENIED = "denied"
  FRIENDSHIP_BLOCKED = "blocked"

  scope :pending, -> { where(status: FRIENDSHIP_PENDING) }
  scope :accepted, -> { where(status: FRIENDSHIP_ACCEPTED) }
  scope :requested, -> { where(status: FRIENDSHIP_REQUESTED) }
  scope :denied, -> { where(status: FRIENDSHIP_DENIED) }
  scope :blocked, -> { where(status: FRIENDSHIP_BLOCKED) }

  belongs_to :user
  belongs_to :friend, class_name: 'User', foreign_key: 'friend_id'
  
  after_destroy do |f|
    User.decrement_counter(:friends_count, f.user_id) if f.status == FRIENDSHIP_ACCEPTED
  end

  def pending?
    status == FRIENDSHIP_PENDING
  end

  def accepted?
    status == FRIENDSHIP_ACCEPTED
  end

  def requested?
    status == FRIENDSHIP_REQUESTED
  end

  def denied?
    status == FRIENDSHIP_DENIED
  end

  def blocked?
    status == FRIENDSHIP_BLOCKED
  end

  def accept!
    unless accepted?
      self.transaction do
        User.increment_counter(:friends_count, user_id)
        update_attribute(:status, FRIENDSHIP_ACCEPTED)
        update_attribute(:accepted_at, Time.now)
      end
    end
  end

  def deny!
    self.transaction do
      update_attribute(:status, Circle::Friendship::FRIENDSHIP_DENIED)
      update_attribute(:denied_at, Time.now)
    end
  end

  def block!(add_to_block_list = false)
    self.transaction do
      update_attribute(:status, Circle::Friendship::FRIENDSHIP_BLOCKED)
      update_attribute(:blocked_at, Time.now)
      self.user.users_blocked.create(blocked_user_id: self.friend.id) if add_to_block_list
    end
  end

end