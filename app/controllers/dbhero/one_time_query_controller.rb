require_dependency "dbhero/application_controller"

module Dbhero
  class OneTimeQueryController < ApplicationController
    before_action :check_auth
    before_action :set_dataclip_params
    respond_to :html, :csv

    def index
      if dataclip_raw_query_present?
        @dataclip = Dataclip.new(@dataclip_params.merge(one_time_query: true))
        @dataclip.otq_result
      else
        @dataclip = Dataclip.new
      end

      respond_to do |format|
        format.html
        format.csv do
          send_data @dataclip.csv_string, type: "text/csv", disposition: "attachment; filename=one_time_query-#{DateTime.now.strftime("%Y%m%d%H%M")}.csv"
        end
      end
    end

    private

    def dataclip_raw_query_present?
      params.dig(:dataclip, :raw_query).present?
    end

    def set_dataclip_params
      @dataclip_params ||=
        dataclip_raw_query_present? ?
          params.require(:dataclip).permit(:raw_query, :one_time_query) :
          {}
    end
  end
end
