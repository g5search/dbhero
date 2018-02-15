require_dependency "dbhero/application_controller"

module Dbhero
  class OneTimeQueryController < ApplicationController
    before_action :check_auth
    respond_to :html, :csv

    def index
      if params.dig(:dataclip, :raw_query).present?
        @dataclip = Dataclip.new(dataclip_query_params.merge(one_time_query: true))
        @dataclip.otq_result
      else
        @dataclip = Dataclip.new
      end

      respond_to do |format|
        format.html
        format.csv do
          send_data @dataclip.csv_string, type: Mime::CSV, disposition: "attachment; filename=one_time_query-#{DateTime.now.strftime("%Y%m%d%H%M")}.csv"
        end
      end
    end

    private

    def dataclip_query_params
      params.require(:dataclip).permit(:raw_query, :one_time_query)
    end
  end
end
