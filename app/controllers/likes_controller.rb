class LikesController < ApplicationController
    before_action :find_post
    before_action :find_like, only: :destroy

    def create
        def create
            if already_liked?
              flash[:notice] = "You can't like more than once"
            else
                @micropost.likes.create(user_id: current_user.id)
                respond_to do |format|
                    format.js
                end
            end
        end
    end

    def destroy
        if !(already_liked?)
            flash[:notice] = "Cannot unlike"
        else
            @like.destroy
            respond_to do |format|
                format.js
            end
        end
    end

    private

    def find_post
        @micropost = Micropost.find(params[:micropost_id])
    end

    def find_like
        @like = @micropost.likes.find(params[:id])
    end

    def already_liked?
        Like.where(user_id: current_user.id, micropost_id: params[:micropost_id]).exists?
    end
end
