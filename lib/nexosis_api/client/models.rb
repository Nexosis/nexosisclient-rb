module NexosisApi
  class Client
    # class to operate on model endpoint in Nexosis API
    # @since 1.3.0
    module Models
      # List all models created in your company, optionally filtered by query parameters
      #
      # @param model_list_query [NexosisApi::ModelListQuery] optionally limit query results by the given parameters
      # @note - query options dates can either be ISO 8601 compliant strings or Date objects.
      # @return [NexosisApi::PagedArray of NexosisApi::ModelSummary] - all models available within the query parameters
      # @raise [NexosisApi::HttpException]
      # @since 3.0.0 - all query parameters use list query class
      def list_models(model_list_query = NexosisApi::ModelListQuery.new)
        model_url = '/models'
        response = self.class.get(model_url, headers: @headers, query: model_list_query.query_parameters)
        raise HttpException.new("There was a problem listing models: #{response.code}.",
                                "listing models with data source name #{datasource_name}",
                                response) unless response.success?
        NexosisApi::PagedArray.new(response.parsed_response,
                                   response.parsed_response['items']
                                   .map { |item| NexosisApi::ModelSummary.new(item) })
      end

      # Get the details of the particular model requested by id
      #
      # @param model_id [String] The unique identifier for the model returned by a create-model session
      # @return [NexosisApi::ModelSummary]
      # @raise [NexosisApi::HttpException]
      # @raise [ArgumentError]
      def get_model(model_id)
        raise ArgumentError, 'Retrieving a model requires that model_id be specified and it is currently null.' if model_id.nil?
        model_url = "/models/#{model_id}"
        response = self.class.get(model_url, @options)
        if (response.success?)
          NexosisApi::ModelSummary.new(response.parsed_response)
        else
          raise HttpException.new("There was a problem getting your model: #{response.code}.", "Could not get model #{model_id}", response)
        end
      end

      # Run a feature set through the model to get predictions
      #
      # @param model_id [String] unique identifier of model to use
      # @param feature_data [Array of Hash] feature columns with values to predict from
      # @param extra_parameters [Hash] name value pairs which should be included in the extraParameters property of the json body of the request.
      # @return [NexosisApi::PredictResponse]
      # @raise [NexosisApi::HttpException]
      # @raise [ArgumentError]
      # @note The feature data shape should match that of the dataset used to create the model.
      #    Any missing features in this request will reduce the quality of the predictions.
      # @note For a classification model you may include the extra parameter 'includeClassScores' to
      #    get scores back for each class, not just the chosen class.
      def predict(model_id, feature_data, extra_parameters = {})
        raise ArgumentError, 'Running predictions requires that model_id be specified and it is currently empty.' if model_id.nil? || model_id.empty?
        raise ArgumentError, 'Running predictions requires that feature_data be specified and it is currently empty.' if feature_data.nil? || feature_data.empty?
        predict_url = "/models/#{model_id}/predict"
        feature_data = [feature_data] unless feature_data.kind_of?(Array)
        response = self.class.post(predict_url, headers: @headers, body: { 'data': feature_data, 'extraParameters': extra_parameters }.to_json)
        if (response.success?)
          NexosisApi::PredictResponse.new(model_id, response.parsed_response)
        else
          raise HttpException.new("There was a problem predicting from your model: #{response.code}.",
                                  "Could not start predict for #{model_id}",
                                  response)
        end
      end

      # Remove an existing model
      #
      # @param model_id [String] the unique id of the model to remove.
      # @raise [NexosisApi::HttpException]
      # @raise [ArgumentError]
      def remove_model(model_id)
        raise ArgumentError, 'Deleting a model requires that model_id be specified and it is currently empty.' if model_id.nil? || model_id.empty?
        delete_url = "/models/#{model_id}"
        response = self.class.delete(delete_url, @options)
        unless (response.success?)
          raise HttpException.new("There was a problem deleting your model: #{response.code}.",
                                  "Could not delete #{model_id}",
                                  response)
        end
      end

      # Deletes multiple models based on the provided filter criteria.
      # @param datasource_name [String] remove all models created by this datasource
      # @param begin_date [DateTime] remove all models created after this date/time - inclusive. May be a ISO 8601 compliant string.
      # @param end_date [DateTime] remove all models created before this date/time - inclusive. May be a ISO 8601 compliant string.
      # @raise [NexosisApi::HttpException]
      # @raise [ArgumentError]
      # @note - Use with great care. This permanently removes trained models.
      #    All parameters are indepdently optional, but one must be sent.
      def remove_models(datasource_name = nil, begin_date = nil, end_date = nil)
        params_unset = datasource_name.nil?
        params_unset &= begin_date.nil?
        params_unset &= end_date.nil?
        raise ArgumentError, 'Must set one of the method parameters.' if params_unset
        delete_url = '/models'
        query = {}
        query.store('dataSourceName', datasource_name) unless datasource_name.nil?
        query.store('createdAfterDate', begin_date) unless begin_date.nil?
        query.store('createdBeforeDate', end_date) unless end_date.nil?
        response = self.class.delete(delete_url, headers: @headers, query: query)
        unless (response.success?)
          raise HttpException.new("There was a problem deleting your models: #{response.code}.",
                                  'Could not delete models',
                                  response)
        end
      end
    end
  end
end
