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

  def filter_movies(ratingList)
    @titleSelected = false
    @dateSelected = false
    ratings = ratingList.keys
    @rating_selected.keys.each do |rating|
      @rating_selected[rating] = ratings.include? rating
    end
    @movies = Movie.where(rating: ratings)
  end

  def index
    @movies = Movie.all
    
    if (not params[:ratings] and session[:ratings]) or (not params[:func] and session[:func])
      #Use the param value if it exists, and the session value otherwise. This has to be done in one redirect.
      ratValue = params[:ratings] ? params[:ratings] : session[:ratings]
      funcValue = params[:func] ? params[:func] : session[:func]
      
      flash.keep
      #Do a final check for entirely missing values...
      if ratValue and funcValue
        redirect_to movies_path({:ratings => ratValue, :func => funcValue})
      elsif ratValue
        redirect_to movies_path({:ratings => ratValue})
      elsif funcValue
        redirect_to movies_path({:func => funcValue})
      end
    end
    
    if params[:ratings]
      filter_movies(params[:ratings])
      session[:ratings] = params[:ratings]
    end
    
    if params[:func] == "tsort"
      @movies = @movies.order(:title)
      @titleSelected = true
      @dateSelected = false
      session[:func] = "tsort"
    elsif params[:func] == "dsort"
      @movies = @movies.order(:release_date)
      @dateSelected = true
      @titleSelected = false
      session[:func] = "dsort"
    else
      @titleSelected = false
      @dateSelected = false
    end
    
  end

  def new
    # default: render 'new' template
  end

  def create
    session.clear
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
