require 'helper'

describe NexosisApi::Client::Contest do

  describe '#get_session_contest', vcr: { cassette_name: 'session_contest' } do
    context 'given a completed session' do
      it 'provides lists of algos' do
        actual = test_client.get_session_contest(existing_session)
        expect(actual).to be_a(NexosisApi::SessionContest)
        expect(actual.champion).to be_a(NexosisApi::AlgorithmContestant)
        expect(actual.session_id).to eql(existing_session)
      end
    end
  end

  describe '#get_contest_champion', vcr: { cassette_name: 'session_champion' } do
    context 'given a successful session' do
      it 'returns the champion with data' do
        actual = test_client.get_contest_champion(existing_session)
        expect(actual).to be_a(NexosisApi::AlgorithmContestant)
        expect(actual.data).to be_a(Array)
      end
    end
  end

  describe '#get_contestants', vcr: { cassette_name: 'session_contestants' } do
    context 'given a successful session' do
      it 'returns all contestant algos' do
        actual = test_client.get_contestants(existing_session)
        expect(actual).to be_a(Array)
        expect(actual[0]).to be_a(NexosisApi::AlgorithmContestant)
        expect(actual[0].id).to_not be_nil
      end
    end
  end

  describe '#get_contestant_results', vcr: { cassette_name: 'session_contestant_data' } do
    context 'given a session and contestant' do
      it 'returns contestant with data' do
        contestant = test_client.get_contestants(existing_session).first
        actual = test_client.get_contestant_results(existing_session, contestant.id)
        expect(actual).to be_a(NexosisApi::AlgorithmContestant)
        expect(actual.data).to be_a(Array)
      end
    end
  end

  describe '#get_selection_metrics', vcr: { cassette_name: 'session_selection_metrics' } do
    context 'given a successful session' do
      it 'provides dataset metrics' do
        actual = test_client.get_selection_metrics(existing_session)
        expect(actual).to be_a(NexosisApi::SessionSelectionMetrics)
      end
    end
  end
end

private

@session_id = nil

def existing_session
  if @session_id.nil?
    sessions = test_client.list_sessions({}, 0, 5)
    completed = sessions.select { |s| s.status == 'completed' }.first
    @session_id = completed.session_id
  end
  @session_id
end

def paid_api_key
  ENV['NEXOSIS_PAID_API_TESTKEY']
end
