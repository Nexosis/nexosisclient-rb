module NexosisApi
  class Client
    # Session Contest-based API operations
    #
    # @see http://docs.nexosis.com/
    # @since 2.0.0
    module Contest

      # @return [NexosisApi::SessionContest]
      def get_session_contest(session_id)
        contest_url = "/sessions/#{session_id}/contest"
      end

      # @return [NexosisApi::AlgorithmContestant]
      def get_contest_champion(session_id)
        champion_url = "/sessions/#{session_id}/contest/champion"
      end

      # @return [Array of NexosisApi::AlgorithmContestant]
      def get_contestants(session_id)
        contestants_url = "/sessions/#{session_id}/contest/contestants"
      end

      # @return [NexosisApi::AlgorithmContestant]
      def get_contestant_results(session_id, contestant_id)
        contestant_url = "/sessions/#{session_id}/contest/contestants/#{contestant_id}"
      end

      # @return [NexosisApi::SessionSelectionMetrics]
      def get_selection_metrics(session_id)
        selection_url = "/sessions/#{session_id}/contest/selection"
      end
    end
  end
end
