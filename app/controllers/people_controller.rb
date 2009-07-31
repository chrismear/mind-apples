class PeopleController < ApplicationController
  resources_controller_for :people
  before_filter :populate_page_code, :only => [:create]

  response_for :create do |format|
    format.html do
      if @resource_saved
        redirect_to edit_person_path(resource)
      end
    end
  end

  protected

  def new_resource(attributes = (params[resource_name] || {}))
    resource = resource_service.new attributes
    resource.ensure_corrent_number_of_mindapples
    resource
  end

  def populate_page_code
    params["person"]["page_code"] = PageCode.code
  end
end
