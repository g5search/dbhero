require_dependency "dbhero/application_controller"
require_dependency "responders"
require_dependency "has_scope"

module Dbhero
  class DataclipsController < ApplicationController
    before_action :check_auth, except: [:show]
    before_action :set_dataclip, only: [:show, :edit, :update, :destroy]
    has_scope :search
    respond_to :html, :csv

    def index
      @dataclips = apply_scopes(Dataclip.ordered)
    end

    def show
      check_auth if @dataclip.private?
      @dataclip.query_result

      respond_to do |format|
        format.html do
          return render :show, layout: false if request.xhr?
        end

        format.csv do
          send_data @dataclip.csv_string, type: "text/csv", disposition: "attachment; filename=#{@dataclip.description} - #{Date.today.to_s}.csv"
        end
      end
    end

    def new
      @dataclip = Dataclip.new
    end

    def edit
      @dataclip.query_result
    end

    def create
      @dataclip = Dataclip.create(dataclip_params.merge(user: user_representation))
      respond_with @dataclip, location: edit_dataclip_path(@dataclip),notice: 'Dataclip was successfully created.'
    end

    def update
      @dataclip.assign_attributes(dataclip_params)
      if @dataclip.query_valid?
        @dataclip.save
      end
      respond_with @dataclip, location: edit_dataclip_path(@dataclip), notice: 'Dataclip was successfully updated.'
    end

    def destroy
      @dataclip.destroy
      redirect_to dataclips_url, notice: 'Dataclip was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_dataclip
        @dataclip = Dataclip.find_by_token(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def dataclip_params
        params.require(:dataclip).permit(:description, :raw_query, :private)
      end
  end
end
