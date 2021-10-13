class MoviesController < ApplicationController


  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    @all_ratings = Movie.all_ratings
    @ratings_to_show = []
    @ratings_to_show = params[:ratings].keys unless params[:ratings].nil?
    
    if !(params.has_key?(:ratings)) 
        if session[:ratings]   #redirect if there are no parameters for ratings but we have ratings stored in session
          redirect_to movies_path(:ratings => session[:ratings]) 
        else
          session[:ratings] = {"G"=>"1", "PG"=>"1", "PG-13"=>"1", "R"=>"1"}
        end
    end    
    @movies = Movie.with_ratings(@ratings_to_show) 
    session[:ratings] = params[:ratings] #update session[:ratings] if we get this point
    
    session[:sort_by] = params[:sort_by] unless params[:sort_by].nil?   #only reassign if it is not nil
    @movies = @movies.order(session[:sort_by]) unless session[:sort_by].nil? #then, use the session[:sort_by] to sort

    case params[:sort_by]
      when 'title'
        @title_header = 'hilite bg-warning' 
      when 'release_date'
        @release_date_header = 'hilite bg-warning'
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
