class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
    @ratings_to_show = session[:ratings]
    @sorted_by = session[:sorted_by]
  end

  def index    
    if params[:ratings].nil? && params[:sorted_by].nil? && (
      !session[:sorted_by].nil? || !session[:ratings].nil?)      
      redirect_to movies_path(sorted_by: session[:sorted_by], ratings: session[:ratings].to_h { |rating| [rating, "1"] } )
    end    
    @all_ratings = Movie.all_ratings
    if session[:sorted_by].nil?
      @title_color = ""
      @release_date_color = ""
    elsif session[:sorted_by] == 'title'
      @title_color = "hilite bg-warning"
      @release_date_color = ""
    else
      @title_color = ""
      @release_date_color = "hilite bg-warning"
    end
    if params[:commit] == "Refresh"
        if params[:ratings]
          @ratings_to_show = params[:ratings].keys
          session[:ratings] = @ratings_to_show          
        else
          session[:ratings] = []
          @ratings_to_show = []
        end
    else
        if session[:ratings].nil? || session[:ratings].empty?
          @ratings_to_show = @all_ratings
        else
          @ratings_to_show = session[:ratings]
        end
    end    
    @movies = Movie.with_ratings(@ratings_to_show)
    if params[:sorted_by]
      @movies = @movies.sorted_by(params[:sorted_by]) || @movies  
      session[:sorted_by] = params[:sorted_by]      
    else
      @movies = @movies.sorted_by(session[:sorted_by]) || @movies  
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

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
