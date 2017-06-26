require 'csv'

module NexosisApi
	class Client
		# Session-based API operations
		#
		# @see http://docs.nexosis.com/
		module Sessions

			# List sessions previously submitted
			#
			# @param query_options [Hash] optionally provide query parameters to limit the search of sessions. 
			# @return[Array of NexosisApi::SessionResponse] with all sessions matching the query or all if no query
			# @note query parameters hash members are dataset_name, event_name, requested_before_date, and requested_after_date. 
			#    After and before dates refer to the session requested date.
			# @example query for just one dataset
			#   sessions = NexosisApi.client.list_sessions :dataset_name => 'MyDataset'
			def list_sessions(query_options = {})
				sessions_url = '/sessions'
				query = { 
					"dataSetName" => query_options[:dataset_name],
					"eventName" => query_options[:event_name],
					"requestedAfterDate" => query_options[:requested_after_date],
					"requestedBeforeDate" => query_options[:requested_before_date],
					"type" => query_options[:type]
				}
				response = self.class.get(sessions_url, :headers => @headers, :query => query)
				if(response.success?)
					all_responses = []
					response.parsed_response["items"].each do |session_hash|
						response_hash = {"session" => session_hash}.merge(response.headers)
						all_responses << NexosisApi::SessionResponse.new(response_hash)
					end
					all_responses
				else
					raise HttpException.new("Could not retrieve sessions","Get all sessions with query #{query_options.to_s}",response)
				end
			end

			# Remove a session
			# @param session_id [String] required session identifier
			def remove_session(session_id)
				if(session_id.to_s.empty?)
					raise ArgumentError 'session_id cannot be empty or nil'
				end
				session_url = '/session/#{session_id.to_s}'
				response = self.class.delete(session_url)	
				if(response.success?)
					return
				else
					raise HttpException.new("Could not delete session with given id","remove session with id #{session_id.to_s}",response)
				end
			end

			# Remove sessions that have been run. All query options are optional and will be used to limit the sessions removed.
			# @param query_options [Hash] optionally provide query parametes to limit the set of sessions removed. 
			# @note query parameters hash members are type, dataset_name, event_name, start_date, and end_date. 
			#    Start and end dates refer to the session requested date.
			#    Results are not removed but then can only be accessed by dataset name
			def remove_sessions(query_options = {})
				sessions_url = '/sessions'
				response = self.class.delete(sessions_url, :headers => @headers, :query => get_query_from_options(query_options))
				if(response.success?)
					return
				else
					raise HttpException.new("Could not remove sessions","Remove sessions with query #{query_options.to_s}",response)
				end
			end
		
			# Forecast from data already saved to the API.
			#
			# @param dataset_name [String] The name of the saved data set that has the data to forecast on.
			# @param target_column [String] The name of the column for which you want predictions.
			# @param start_date [DateTime] The starting date of the forecast period. Can be ISO 8601 string. 
			# @param end_date [DateTime] The ending date of the forecast period. Can be ISO 8601 string.
			# @return [NexosisApi::SessionResponse] providing information about the sesssion
			def create_forecast_session(dataset_name, target_column, start_date, end_date)
				create_session dataset_name, target_column, start_date, end_date
			end

			# Forecast from CSV formatted data.
			#
			# @param csv [CSV] initialized CSV object ready for reading.
			# @param target_column [String] The name of the column for which you want predictions.
			# @param start_date [DateTime] The starting date of the forecast period. Can be ISO 8601 parseable string. 
			# @param end_date [DateTime] The ending date of the forecast period. Can be ISO 8601 parseable string.
			# @return [NexosisApi::SessionResponse] providing information about the sesssion
			# @example load and send local file
			#    mycsv = CSV.read('.\mylocal.csv')
			#    NexosisApi.client(:api_key=>mykey).create_forecast_session_csv(mycsv,'sales','01-01-2017','02-01-2017')
            def create_forecast_session_csv(csv, target_column, start_date, end_date)
				content = process_csv_to_s csv
                create_session(nil, target_column, start_date, end_date, false, nil, "forecast", content)
            end

			# Forecast from data posted in the request.
			#
			# @param json_data [String] Json dataset matching the dataset input schema.
			# @param target_column [String] The name of the column for which you want predictions.
			# @param start_date [DateTime] The starting date of the forecast period. Can be ISO 8601 string. 
			# @param end_date [DateTime] The ending date of the forecast period. Can be ISO 8601 string.
			# @return [NexosisApi::SessionResponse] providing information about the sesssion
			# @see https://developers.nexosis.com/docs/services/98847a3fbbe64f73aa959d3cededb3af/operations/5919ef80a730020dd851f233
			def create_forecast_session_data(json_data, target_column, start_date, end_date)
				create_session nil, target_column, start_date, end_date, false, nil, "forecast", json_data, "application/json"
			end

			# Estimate the cost of a forecast from data already saved to the API.
			#
			# @param dataset_name [String] The name of the saved data set that has the data to forecast on.
			# @param target_column [String] The name of the column for which you want predictions.
			# @param start_date [DateTime] The starting date of the forecast period. Can be ISO 8601 string. 
			# @param end_date [DateTime] The ending date of the forecast period. Can be ISO 8601 string.
			# @return [NexosisApi::SessionResponse] providing information about the sesssion, including the cost
            def estimate_forecast_session(dataset_name, target_column, start_date, end_date)
                create_session dataset_name, target_column, start_date, end_date, true
            end
			
			# Analyze impact for an event with data already saved to the API.
			#
			# @param dataset_name [String] The name of the saved data set that has the data to forecast on.
			# @param target_column [String] The name of the column for which you want predictions.
			# @param start_date [DateTime] The starting date of the impactful event. Can be ISO 8601 string. 
			# @param end_date [DateTime] The ending date of the impactful event. Can be ISO 8601 string.
			# @param event_name [String] The name of the event.
			# @return [NexosisApi::SessionResponse] providing information about the sesssion
            def create_impact_session(dataset_name, target_column, start_date, end_date, event_name)
                create_session dataset_name, target_column, start_date, end_date, false, event_name, "impact"
            end

			# Analyze impact for an event with data in json format.
			#
			# @param json_data [String] Json dataset matching the dataset input schema.
			# @param target_column [String] The name of the column for which you want predictions.
			# @param start_date [DateTime] The starting date of the impactful event. Can be ISO 8601 string. 
			# @param end_date [DateTime] The ending date of the impactful event. Can be ISO 8601 string.
			# @param event_name [String] The name of the event.
			# @return [NexosisApi::SessionResponse] providing information about the sesssion
			# @see https://developers.nexosis.com/docs/services/98847a3fbbe64f73aa959d3cededb3af/operations/5919ef80a730020dd851f233
			def create_impact_session_data(json_data, target_column, start_date, end_date, event_name)
				create_session nil, target_column, start_date, end_date, false, event_name, "impact", json_data, "application/json"
			end
            
			# Estimate the cost of impact analysis for an event with data already saved to the API.
			#
			# @param dataset_name [String] The name of the saved data set that has the data to forecast on.
			# @param target_column [String] The name of the column for which you want predictions.
			# @param start_date [DateTime] The starting date of the impactful event. Can be ISO 8601 string. 
			# @param end_date [DateTime] The ending date of the impactful event. Can be ISO 8601 string.
			# @param event_name [String] The name of the event.
			# @return [NexosisApi::SessionResponse] providing information about the sesssion, including the cost
            def estimate_impact_session(dataset_name, target_column, start_date, end_date, event_name)
                create_session dataset_name, target_column, start_date, end_date, true, event_name, "impact"
            end
            
			# Get the results of the session.
			#
			# @param session_id [String] the Guid string returned in a previous session request
			# @param as_csv [Boolean] indicate whether results should be returned in csv format
			# @return [NexosisApi::SessionResult] SessionResult if parsed, String of csv data otherwise
            def get_session_results(session_id, as_csv = false)
        		session_result_url = "/sessions/#{session_id}/results"
		
		    	if as_csv
			    	@headers["Accept"] = "text/csv"
			    end
			    response = self.class.get(session_result_url, @options)
			    @headers.delete("Accept")

			    if(response.success?)
				    if(as_csv)
					    response.body
				    else
					    NexosisApi::SessionResult.new(response.parsed_response)
				    end
                else
                    raise HttpException.new("There was a problem getting the session: #{response.code}.", "get results for session #{session_id}" ,response)
			    end
		    end

			# Get a specific session by id.
			#
			# @param session_id [String] the Guid string returned in a previous session request
			# @return [NexosisApi::Session] a Session object populated with the session's data
            def get_session(session_id)
                session_url = "/sessions/#{session_id}"
                response = self.class.get(session_url, @options)
                if(response.success?)
                    NexosisApi::Session.new(response.parsed_response)
                else
                    raise HttpException.new("There was a problem getting the session: #{response.code}.", "getting session #{session_id}" ,response)
			    end
            end
        private
			def create_session(dataset_name, target_column, start_date, end_date, is_estimate=false, event_name = nil, type = "forecast", content = nil, content_type = "text/csv")
				session_url = "/sessions/#{type}"
				query = { 
					"targetColumn" => target_column,
					"startDate" => start_date.to_s,
					"endDate" => end_date.to_s,
					"isestimate" => is_estimate.to_s
				}
				query["dataSetName"] = dataset_name.to_s unless dataset_name.to_s.empty?
				if(event_name.nil? == false)
					query["eventName"] = event_name
				end
                if content.nil? == false
                    headers = {"api-key" => @api_key, "content-type" => content_type}
                    response = self.class.post(session_url, {:headers => headers, :query => query, :body => content})
                else
                    response = self.class.post(session_url, :headers => @headers, :query => query)
                end
				if(response.success?)
					session_hash = {"session" => response.parsed_response}.merge(response.headers)
					NexosisApi::SessionResponse.new(session_hash)
				else
					raise HttpException.new("Unable to create new #{type} session","Create session for dataset #{dataset_name}",response)
				end
			end

			def get_query_from_options(options)
				query = { 
					"dataSetName" => options[:dataset_name],
					"eventName" => options[:event_name],
					"startDate" => options[:start_date],
					"endDate" => options[:end_date],
					"type" => options[:type]
				}
				query
			end
		end
	end
end