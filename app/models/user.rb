class User < ApplicationRecord
    has_many :microposts, dependent: :destroy
    has_many :nanoposts, dependent: :destroy
    has_many :likes, dependent: :destroy
    has_one_attached :avatar
    has_many :active_relationships, class_name: "Relationship", foreign_key: "follower_id", dependent: :destroy
    has_many :following, through: :active_relationships, source: :followed
    has_many :passive_relationships, class_name:  "Relationship", foreign_key: "followed_id", dependent: :destroy
    has_many :following, through: :active_relationships,  source: :followed
    has_many :followers, through: :passive_relationships, source: :follower
    attr_accessor :remember_token, :remove_user_avatar
    before_save { email.downcase! }
    after_save :purge_avatar, if: :remove_user_avatar
    validates :name, presence: true, length: { maximum: 50}
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :email, presence: true,
                      length: { maximum: 255 },
                      format: {with: VALID_EMAIL_REGEX},
                      uniqueness: true
    has_secure_password
    validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
    validates :avatar,   content_type: { in: %w[image/jpeg image/png],
        message: "must be a valid image format" },
        size: { less_than: 5.megabytes,
        message:     "should be less than 5MB" }
    validates :bio, length: { maximum: 250 }
    validates :location, length: { maximum: 30 }

    # Returns the hash digest of the given string
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end

    # Generates a random token
    def User.new_token
        SecureRandom.urlsafe_base64
    end

    # Remembers a user in the database for use in persistent sessions.
    def remember
        self.remember_token = User.new_token
        update_attribute(:remember_digest, User.digest(remember_token))
    end

    # Returns true if the given token matches the digest.
    def authenticated?(remember_token)
        return false if remember_digest.nil?
        BCrypt::Password.new(remember_digest).is_password?(remember_token)
    end

    # Forgets a user.
    def forget
        update_attribute(:remember_digest, nil)
    end

    # Returns a user's status feed.
    def feed
        following_ids = "SELECT followed_id FROM relationships WHERE  follower_id = :user_id"
        Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: id)
    end

    # Follows a user.
    def follow(other_user)
        following << other_user unless self == other_user
    end

    # Unfollows a user.
    def unfollow(other_user)
        following.delete(other_user)
    end

    # Returns true if the current user is following the other user.
    def following?(other_user)
        following.include?(other_user)
    end

    private

    # Removes the avatar if user removes avatar in (views/users/edit)
    def purge_avatar
        avatar.purge_later
    end
end