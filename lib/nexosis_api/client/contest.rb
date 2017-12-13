module NexosisApi
  class Client
    # Session Contest-based API operations
    #
    # @see http://docs.nexosis.com/
    # @since 2.0.0
    module Contest

      # @return [NexosisApi::SessionContest]
      def get_session_contest(session_id)
        raise ArgumentError, 'session_id was not provided and is not optional ' if session_id.to_s.empty?
        contest_url = "/sessions/#{session_id}/contest"
        response = self.class.get(contest_url, headers: @headers)
        raise HttpException.new("There was a problem getting session contest #{response.code}.",
                                "getting contest for #{session_id}",
                                response) unless response.success?
        NexosisApi::SessionContest.new(response.parsed_response)
      end

      # @return [NexosisApi::AlgorithmContestant]
      def get_contest_champion(session_id)
        raise ArgumentError, 'session_id was not provided and is not optional ' if session_id.to_s.empty?
        champion_url = "/sessions/#{session_id}/contest/champion"
        response = self.class.get(champion_url, headers: @headers)
        raise HttpException.new("There was a problem getting session champion #{response.code}.",
                                "getting champion for #{session_id}",
                                response) unless response.success?
        NexosisApi::AlgorithmContestant.new(response.parsed_response)
      end

      # @return [Array of NexosisApi::AlgorithmContestant]
      def get_contestants(session_id)
        raise ArgumentError, 'session_id was not provided and is not optional ' if session_id.to_s.empty?
        contestants_url = "/sessions/#{session_id}/contest/contestants"
        response = self.class.get(contestants_url, headers: @headers)
        raise HttpException.new("There was a problem getting session contestants #{response.code}.",
                                "getting contestants for #{session_id}",
                                response) unless response.success?
        response.parsed_response['items'].map { |c| NexosisApi::AlgorithmContestant.new(c) }
      end

      # @return [NexosisApi::AlgorithmContestant]
      def get_contestant_results(session_id, contestant_id)
        raise ArgumentError, 'session_id was not provided and is not optional ' if session_id.to_s.empty?
        raise ArgumentError, 'contestant_id was not provided and is not optional ' if contestant_id.to_s.empty?
        contestant_url = "/sessions/#{session_id}/contest/contestants/#{contestant_id}"
        response = self.class.get(contestant_url, headers: @headers)
        raise HttpException.new("There was a problem getting session contestant result #{response.code}.",
                                "getting contestant result for #{session_id}:#{contestant_id}",
                                response) unless response.success?
        NexosisApi::AlgorithmContestant.new(response.parsed_response)
      end

      # @return [NexosisApi::SessionSelectionMetrics]
      def get_selection_metrics(session_id)
        raise ArgumentError, 'session_id was not provided and is not optional ' if session_id.to_s.empty?
        selection_url = "/sessions/#{session_id}/contest/selection"
        response = self.class.get(selection_url, headers: @headers)
        raise HttpException.new("There was a problem getting session selection metrics #{response.code}.",
                                "getting selection metrics for #{session_id}",
                                response) unless response.success?
        NexosisApi::SessionSelectionMetrics.new(response.parsed_response)
      end
    end
  end
end
