class QuestionnairesController < ApplicationController
  # GET /questionnaires
  # GET /questionnaires.xml
  def index
    @questionnaires = Questionnaire.find(:all)

    respond_to do |format|
      format.html # index.rhtml
      format.xml  { render :xml => @questionnaires.to_xml }
    end
  end

  # GET /questionnaires/1
  # GET /questionnaires/1.xml
  def show
    @questionnaire = Questionnaire.find(params[:id])

    respond_to do |format|
      format.html # show.rhtml
      format.xml  { render :xml => @questionnaire.to_xml }
    end
  end

  # GET /questionnaires/new
  def new
    @questionnaire = Questionnaire.new
  end

  # GET /questionnaires/1;edit
  def edit
    @questionnaire = Questionnaire.find(params[:id])
  end

  # POST /questionnaires
  # POST /questionnaires.xml
  def create
    @questionnaire = Questionnaire.new(params[:questionnaire])

    respond_to do |format|
      if @questionnaire.save
        flash[:notice] = 'Questionnaire was successfully created.'
        format.html { redirect_to questionnaire_url(@questionnaire) }
        format.xml  { head :created, :location => questionnaire_url(@questionnaire) }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @questionnaire.errors.to_xml }
      end
    end
  end

  # PUT /questionnaires/1
  # PUT /questionnaires/1.xml
  def update
    @questionnaire = Questionnaire.find(params[:id])

    respond_to do |format|
      if @questionnaire.update_attributes(params[:questionnaire])
        flash[:notice] = 'Questionnaire was successfully updated.'
        format.html { redirect_to questionnaire_url(@questionnaire) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @questionnaire.errors.to_xml }
      end
    end
  end

  # DELETE /questionnaires/1
  # DELETE /questionnaires/1.xml
  def destroy
    @questionnaire = Questionnaire.find(params[:id])
    @questionnaire.destroy

    respond_to do |format|
      format.html { redirect_to questionnaires_url }
      format.xml  { head :ok }
    end
  end

  def pagelist
    @questionnaire = Questionnaire.find(params[:id])
    render :partial => 'pagelist', :locals => { :questionnaire => @questionnaire }
  end
end
