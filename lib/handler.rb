# frozen_string_literal: true

class Handler
  def initialize(container)
    @container = container
  end

  def process(event:)
    normalised_event = JSON.parse(JSON.generate(event))

    etl_stage = ENV['ETL_STAGE'].capitalize

    use_case_constant = UseCase.const_get(etl_stage)

    normalised_event['Records'].each do |message|
      request = Boundary.const_get(etl_stage + 'Request').new message['body']
      use_case = use_case_constant.new(request, @container)

      use_case.execute
    end
  rescue NameError
    raise Errors::EtlStageInvalid
  end
end
