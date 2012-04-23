class ReportsController < ApplicationController
  def container
    @start_date = params[:start_date].to_date
    @end_date = params[:end_date].to_date rescue Date.today
    @type = params[:type].gsub('_',' ').humanize + " (#{@start_date} to #{@end_date})"
    @title = params[:type].gsub('_',' ').humanize 


    case params[:type]
      when "missed_appointments"
        @patients = PatientService.report("Missed appointments" , @start_date , @end_date)
      when "sms_status"
        @patients = PatientService.report("SMS status" , @start_date , @end_date)
      when "trace_outcomes"
        @patients = PatientService.report("Outcome status" , @start_date , @end_date)
    end
  end


end
