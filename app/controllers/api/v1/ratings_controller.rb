module Api
  module V1
    class RatingsController < ApplicationController
      def create
        result = PostRatingService.new(rating_params).call

        if result.success?
          render json: {
            rating: result.rating,
            average_rating: result.average_rating
          }, status: :created
        else
          render json: { errors: result.errors }, status: :unprocessable_entity
        end
      end

      private

      def rating_params
        params.require(:rating).permit(:post_id, :user_id, :value)
      end
    end
  end
end
