module UsersHelper
    # Returns the avatar of the user
    def avatar_for(user)
        user.avatar.attached? ?
            image_tag(user.avatar, alt:user.name, class: "avatar") :
            image_tag("default_user.png", alt: user.name, class: "avatar")
    end
end
