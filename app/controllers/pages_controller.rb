class PagesController < ApplicationController
  layout "answer"
  before_filter :get_questionnaire

  # GET /pages
  # GET /pages.xml
  def index
    @pages = Page.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @pages.to_xml }
    end
  end

  # GET /pages/1
  # GET /pages/1.xml
  def show
    @page = Page.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @page.to_xml }
    end
  end

  # GET /pages/new
  def new
    @page = Page.new
  end

  # GET /pages/1;edit
  def edit
    @page = Page.find(params[:id])
  end

  # POST /pages
  # POST /pages.xml
  def create
    p = params[:page] || {}
    p[:questionnaire_id] = @questionnaire.id
    @page = Page.new(p)

    respond_to do |format|
      if @page.save
        flash[:notice] = 'Page was successfully created.'
        format.html { redirect_to page_url(@questionnaire, @page) }
        format.xml  { head :created, :location => page_url(@questionnaire, @page) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @page.errors.to_xml }
      end
    end
  end

  # PUT /pages/1
  # PUT /pages/1.xml
  def update
    @page = Page.find(params[:id])

    respond_to do |format|
      if @page.update_attributes(params[:page])
        flash[:notice] = 'Page was successfully updated.'
        format.html { redirect_to page_url(@questionnaire, @page) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @page.errors.to_xml }
      end
    end
  end

  # DELETE /pages/1
  # DELETE /pages/1.xml
  def destroy
    @page = Page.find(params[:id])
    @page.destroy

    respond_to do |format|
      format.html { redirect_to pages_url(@questionnaire) }
      format.xml  { head :ok }
    end
  end

  def get_questionnaire
    @questionnaire = Questionnaire.find(params[:questionnaire_id])
  end
end
