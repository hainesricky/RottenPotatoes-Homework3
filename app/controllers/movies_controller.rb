class MoviesController < ApplicationController
  
  def initialize
    @all_ratings = Movie.all_ratings
    @rating_selected = {}
    @all_ratings.each do |rating|
      @rating_selected[rating] = true
    end
    super
  end

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    if params[:func] == "tsort"
      @movies = Movie.all.order(:title)
      @titleSelected = true
      @dateSelected = false
    elsif params[:func] == "dsort"
      @movies = Movie.all.order(:release_date)
      @dateSelected = true
      @titleSelected = false
    elsif params[:ratings]
      @titleSelected = false
      @dateSelected = false
      ratings = params[:ratings].keys
      @rating_selected.keys.each do |rating|
        @rating_selected[rating] = ratings.include? rating
      end
      @movies = Movie.where(rating: ratings)
    else
      @titleSelected = false
      @dateSelected = false
      @movies = Movie.all
    end
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
