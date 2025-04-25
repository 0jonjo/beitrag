module Api
    module V1
        class PostsController < ApplicationController
            def create
                @post = Post.new(post_params)
                result = PostCreatorService.new(@post).call

                if result.success?
                    render json: { post: result.created_post, user: result.user }, status: :created
                else
                    render json: { errors: result.errors }, status: :unprocessable_entity
                end
            end

            private

            def post_params
                params.require(:post).permit(:title, :body, :ip, :user_id)
            end
        end
    end
end
