class TracedOutcomesController < ApplicationController
  def update
    patient_id = params[:patient_id]
    outcome_id = params[:outcome_id]

    outcome = PatientTraceOutcome.new()
    outcome.patient_id = patient_id
    outcome.trace_outcome_id = outcome_id
    outcome.outcome_date = Date.today
    outcome.date_created = Time.now()
    outcome.save
    render :text => "updated" and return
  end
end
