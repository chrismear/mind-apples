class MindapplesController < ApplicationController

  def index
    unless params['mindapple'].blank?
      @mindapples = Mindapple.search_by_suggestion(params['mindapple']).paginate(:page => params[:page], :per_page => 10)
      @search_message = "Sorry, it seems that we can't find what you are looking for." if @mindapples.size == 0
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @mindapples }
    end
  end

end
