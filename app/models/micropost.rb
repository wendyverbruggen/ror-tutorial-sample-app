class Micropost < ActiveRecord::Base
  belongs_to :user, class_name: "User"
  belongs_to :in_reply_to, foreign_key: "in_reply_to", class_name: "User"

  default_scope -> { order('created_at DESC') }

  validates :content, presence: true, length: { maximum: 140 }
  validates :user_id, presence: true

  # before saving the micropost to the database we check if it starts with an @reply, 
  # and if so we want to fill in the in_reply_to field with the id of the user replied to
  before_save :check_reply_to

  def Micropost.from_users_followed_by(user)
    followed_user_ids = "SELECT followed_id FROM relationships WHERE follower_id = :user_id"
    where("(user_id IN (#{followed_user_ids}) AND (in_reply_to IS NULL OR in_reply_to = :user_id)) OR user_id = :user_id OR in_reply_to = :user_id", user_id: user)
  end

  def Micropost.search(search, subset=false)
    if search
      if !subset # could be more efficient.. getting it to work first :) 
        where("UPPER(content) LIKE :search", search: "%#{search}%".upcase)   
      else
        where("UPPER(content) LIKE :search AND id IN (:subset)", search: "%#{search}%".upcase, subset: subset)
      end
    else
      subset unless !subset
      Micropost.all
    end
  end

  private

    def check_reply_to
      first_word = self.content.split(" ")[0]
      if first_word.slice(0) == "@"
        # make this is a valid username (format: @123-the-users-name)
        username_components = first_word.slice(1..-1).split("-", 2)
         
        reply_to_user = User.find(username_components[0].to_i)
        if reply_to_user && reply_to_user.name.downcase.gsub(/[-]/, ' ') == username_components[1].downcase.gsub(/[-]/, ' ')
          self.in_reply_to = reply_to_user
        end
      end
    end

end
