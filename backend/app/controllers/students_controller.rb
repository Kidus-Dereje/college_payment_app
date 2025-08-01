class StudentsController < ApplicationController
  # GET /students/credentials_summary
  # params[:created] is expected to be an array of hashes (email, password, name, etc)
  def credentials_summary
    # Accept created as JSON string if passed as a param
    @created = params[:created].is_a?(String) ? JSON.parse(params[:created], symbolize_names: true) : (params[:created] || [])
    render :credentials_summary
  end
end
