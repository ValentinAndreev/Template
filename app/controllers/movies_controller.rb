class MoviesController < ApplicationController
  before_action :find_movie, except: [:index]
  before_action :rating, only: [:show]  

  def index
    @movies = FindMovies.new(Movie.all).call(movie_params)
  end

  def show
    @my_review = Review.where(user_id: current_user.id, movie_id: @movie)
    @reviews = Review.where(movie_id: @movie)
    respond_to do |format|
      format.html
      format.js
    end
  end

  def recommendations
    @recommendations = @movie.recommendations
  end

  private

  def movie_params
    params.permit(:recommendation, :page, :current_user, :search, :genres, :sort, :order).merge!(current_user: current_user)
  end

  def find_movie
    @movie = @commentable = Movie.find(params[:id])
    @vote = Vote.find_or_create_by(user_id: current_user.id, movie_id: @movie)
    @comments = @movie.comments.order(:created_at).all
  end

  def rating
    votes = @movie.votes.pluck(:value)
    votes_count = votes.count
    @rating = votes_count > 0 ? (votes.sum.to_f/votes_count.to_f).round(2) : 0
    @votes = votes.count
  end
end
