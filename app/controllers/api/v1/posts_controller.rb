module Api
  module V1
    class PostsController < ApplicationController
      def index
          limit = params.fetch(:limit, 10).to_i
          posts = Post.top_rated(limit)

          render json: posts.map { |post|
            {
              id: post.id,
              title: post.title,
              body: post.body,
              average_rating: post.average_rating
            }
          }
      end

      def create
          result = PostCreatorService.new(post_params).call

          if result.success?
              render json: { post: result.created_post, user: result.user }, status: :created
          else
              render json: { errors: result.errors }, status: :unprocessable_entity
          end
      end

      def ips_authors
        ips_with_multiple_authors = Post.ips_with_multiple_authors

        result = ips_with_multiple_authors.map do |record|
          {
            ip: record.ip,
            logins: record.logins
          }
        end

        render json: result
      end

      private

      def post_params
          params.require(:post).permit(:title, :body, :ip, :login)
      end
    end
  end
end
