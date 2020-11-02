class NanopostsController < ApplicationController
    before_action :logged_in_user, only: [:create, :destroy]
    before_action :correct_user, only: :destroy

    def create
        @nanopost = current_user.nanoposts.build(nanopost_params)
        @nanopost.image.attach(params[:nanopost][:image])
        @nanopost.micropost_id = params[:micropost_id]
        if @nanopost.save
            flash[:success] = "Nanopost created!"
            redirect_back(fallback_location: root_path)
        else
            render 'static_pages/home'
        end
    end

    def destroy
        @nanopost.destroy
        flash[:success] = "Nanopost deleted"
        if request.referrer.nil? || request.referrer == nanopost_url
            redirect_back(fallback_location: root_path)
        else
            redirect_to request.referrer
      end
    end

    private

    def nanopost_params
        params.require(:nanopost).permit(:content, :image)
    end

    def correct_user
        @nanopost = current_user.nanoposts.find_by(id: params[:id])
        redirect_to root_url if @nanopost.nil?
    end
end