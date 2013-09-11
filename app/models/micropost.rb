class Micropost < ActiveRecord::Base
  belongs_to :user
  belongs_to :in_reply_to, class_name: "User"

  default_scope -> { order('created_at DESC') }

  validates :content, presence: true, length: { maximum: 140 }
  validates :user_id, presence: true

  # before saving the micropost to the database we check if it starts with an @reply, 
  # and if so we want to fill in the in_reply_to field with the id of the user replied to
  before_save :check_reply_to

  def self.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id", user_id: user)
  end

  private

    def check_reply_to
      first_word = self.content.split(" ")[0]
      if first_word.slice(0) == "@"
        # make this is a valid username (format: @123-the-users-name)
        username_components = first_word.slice(1..-1).split("-", 2)
         
        user = User.find(username_components[0].to_i)
        if user && user.name.downcase.gsub(/[-]/, ' ') == username_components[1].downcase.gsub(/[-]/, ' ')
          self.in_reply_to = user
        end
      end
    end

end
