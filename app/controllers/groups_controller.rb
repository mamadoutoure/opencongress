class GroupsController < ApplicationController
  before_filter :login_required, :except => [ :show, :index ]
  
  def new
    @page_title = 'Create a New OpenCongress Group'
    @group = Group.new
    @group.join_type = 'ANYONE'
    @group.invite_type = 'ANYONE'
    @group.post_type = 'ANYONE'
  end
  
  
  def create
    @group = Group.new(params[:group])
    @group.user = current_user
    
    respond_to do |format|
      if @group.save
        format.html { redirect_to(new_group_group_invite_path(@group), :notice => 'Group was successfully created.') }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def show
    @group = Group.find(params[:id])
    
    @page_title = "#{@group.name} - MyOC Groups"
  end
  
  def index
    @page_title = 'OpenCongress Groups'

    unless params[:q].blank? and params[:pvs_category].blank?
      where = []
      
      unless params[:q].blank?
        where = ["(groups.name ILIKE ? OR groups.description ILIKE ?)", "%#{params[:q]}%", "%#{params[:q]}%"]
      end
      
      unless params[:pvs_category].blank?
        if where.empty?
          where = ["groups.pvs_category_id=?", params[:pvs_category]]
        else
          where[0] += " AND groups.pvs_category_id=?"
          where << params[:pvs_category]
        end
      end
      
      @groups = Group.where(where)
    else
      @groups = Group.all #where("join_type='ANYONE'")
    end
    
    respond_to do |format|
      format.html
      format.js
      format.json  { render :json => @groups }
    end
  end
end