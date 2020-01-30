require 'rspec'

require 'json'

describe 'Acceptance::Load' do
  context 'when no data is supplied in the event body' do
    it 'raises an error' do
      event = JSON.parse File.open('spec/events/sqs-empty-event.json').read

      request = Boundary::LoadRequest.new event['Records'][0]['body']

      expect do
        UseCase::Load.new request
      end.to raise_error instance_of Errors::RequestWithoutBody
    end
  end
end
