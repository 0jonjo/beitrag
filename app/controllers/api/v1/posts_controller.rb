module Api
    module V1
        class PostsController < ApplicationController
            def create
                result = PostCreatorService.new(post_params).call

                if result.success?
                    render json: { post: result.created_post, user: result.user }, status: :created
                else
                    render json: { errors: result.errors }, status: :unprocessable_entity
                end
            end

            private

            def post_params
                params.require(:post).permit(:title, :body, :ip, :login)
            end
        end
    end
end
