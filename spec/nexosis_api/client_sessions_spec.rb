require 'helper'
require 'csv'

describe NexosisApi::Client::Sessions do
    describe "#create_forecast_session", :vcr => {:cassette_name => "create_forecast_dataset"} do
        context "given an existing dataset name" do
            it "returns a started session" do
                actual = test_client.create_forecast_session('TestRuby','2014-05-20','2014-05-21','sales')
                expect(actual).to be_instance_of(NexosisApi::SessionResponse)
                expect(actual.type).to eql('forecast')
            end
        end
    end

    describe "#estimate_forecast_session", :vcr  => {:cassette_name => "estimate_forecast_session"} do
        context "given an existing dataset name" do
            it "returns a session response with cost" do
                actual = test_client.estimate_forecast_session('TestRuby','2014-05-20','2014-06-20','sales')
                expect(actual.cost).to eql('3.10 USD')
            end
        end
    end

    describe "#create_impact_session", :vcr  => {:cassette_name => "create_impact_session"} do
        context "given an existing dataset name" do
            it "returns a started session" do
                actual = test_client.create_impact_session('TestRuby','05-01-2014','05-10-2014','test event','sales')
                expect(actual).to be_instance_of(NexosisApi::SessionResponse)
                expect(actual.type).to eql('impact')
            end
        end
    end

    describe "#estimate_impact_session", :vcr  => {:cassette_name => "estimate_impact_session"} do
        context "given an existing dataset name" do
            it "returns a session response with cost" do
                actual = test_client.estimate_impact_session('TestRuby','05-01-2014','05-10-2014', 'test event','sales')
                expect(actual.cost).to eql('0.90 USD')
            end
        end
    end

    describe "#create_impact_session", :vcr  => {:cassette_name => "create_impact_session_fail"} do
        context "given an end date outside the dataset dates" do
            it "throws exception" do
                expect{ test_client.create_impact_session('TestRuby','01-22-2017','02-22-2017', 'test event','sales') }.to raise_error { |error|
                    expect(error).to be_a(NexosisApi::HttpException)
                }
            end
        end
    end

    describe "#get_session_results", :vcr  => {:cassette_name => "get_session_results"} do
        context "given the id of an completed session" do 
            it "returns the results of the session analysis" do
                session = test_client.create_forecast_session("TestRuby",'2014-05-20','2014-05-25','sales')
                loop do
                    status_check = test_client.get_session session.sessionId
                    break if (status_check.status == "completed" || status_check.status == "failed")
                    sleep 5
                end
                actual = test_client.get_session_results session.sessionId
                expect(actual).to be_a(NexosisApi::SessionResult)
                expect(actual.data).not_to be_empty
            end
        end
    end
    
    describe "#list_sessions", :vcr  => {:cassette_name => "list_sessions_dataset"} do
        context "given a request with a dataset name" do
            it "returns an array of all sessions with that dataset" do
                actual = test_client.list_sessions :dataset_name=>'TestRuby'
                expect(actual).to be_a(Array)
                actual_map = actual.map { |s| s.dataSetName }
                expect(actual_map).to all( be_a(String).and include("TestRuby") )
            end
        end
    end

    describe "#list_sessions", :vcr  => {:cassette_name => "list_sessions_eventname"} do
        context "given a request with an event name" do
            it "returns an array of all sessions with that event" do
                actual = test_client.list_sessions :event_name=>'test event'
                expect(actual).to be_a(Array)
                actual_map = actual.map { |s| s.extraParameters["event"] }
                expect(actual_map).to all( be_a(String).and include("test") )
            end
        end
    end

    describe "#list_sessions", :vcr  => {:cassette_name => "list_sessions_dates"} do
        context "given a request with a start and end date" do
            it "returns an array of all sessions within that time frame" do
                start_date = DateTime.strptime('6-14-2017','%m-%d-%Y')
                end_date = DateTime.strptime('6-30-2017','%m-%d-%Y')
                actual = test_client.list_sessions :requested_after_date => start_date, :requested_before_date => end_date
                expect(actual).to be_a(Array)
                actual.each do |sr|
                    requested_date = DateTime.parse(sr.statusHistory.select {|v| v.has_value? "requested"}[0]["date"])
                    expect(requested_date).to be_between(start_date,end_date).inclusive
                end
            end
        end
    end

    describe "#remove_sessions", :vcr  => {:cassette_name => "remove_sessions"} do
        context "given a dataset name" do
            it "removes any session created with that name" do
                #create the session to remove
                existing_dataset = "ToRemoveRuby"
                json = {"columns" => {"timestamp"=> {"dataType"=> "date","role"=> "timestamp"},"sales"=> {"dataType"=> "numeric","role"=> "target"}},"data"=> [{"timestamp"=> "2017-01-01T00:00:00+00:00","sales"=> "2948.74"},{"timestamp"=> "2017-01-02T00:00:00+00:00","sales"=> "1906.35"},{"timestamp"=> "2017-01-03T00:00:00+00:00","sales"=> "4523.42"},{"timestamp"=> "2017-01-04T00:00:00+00:00","sales"=> "4586.85"},{"timestamp"=> "2017-01-05T00:00:00+00:00","sales"=> "4538.04"}]}
                new_dataset = test_client.create_dataset_json(existing_dataset, json)
                new_session = test_client.create_forecast_session(existing_dataset,"2017-01-06","2017-01-10","sales")
                test_client.remove_sessions :dataset_name => existing_dataset
                expect{test_client.get_session(new_session.sessionId)}.to raise_error{ |error|
                    expect(error).to be_a(NexosisApi::HttpException)
                    expect(error.code).to eql(404)
                }
            end
        end
    end

    describe "#create_forecast_session_data", :vcr => {:cassette_name => "create_forecast_session_features"} do
        context "given a metadata specification" do
            it "executes a session with a feature identified" do
                columns = []
                columns << NexosisApi::DatasetColumn.new('transactions',{ "dataType" => NexosisApi::ColumnType::NUMERIC, "role" => NexosisApi::ColumnRole::FEATURE })
                actual  = test_client.create_forecast_session("TestRuby",'2013-07-18','2013-08-28',"sales",'day', columns)
                expect(actual).to be_a(NexosisApi::SessionResponse)
                expect(actual.targetColumn).to eql('sales')
                expect(actual.column_metadata[2].role).to eql(NexosisApi::ColumnRole::FEATURE)
            end
        end
    end

    describe "#create_forecast_session", :vcr => {:cassette_name => "create_session_no_dataset_404"} do
        context "given a dataset name that does not exist" do
            it "fails with a 404 http message" do
                 expect{test_client.create_forecast_session('IDontExist','01-22-2013','02-22-2013','sales')}.to raise_error{ |error|
                    expect(error).to be_a(NexosisApi::HttpException)
                    expect(error.code).to eql(404)
                 }
            end
        end
    end

    describe "#create_forecast_session", :vcr => {:cassette_name => "create_session_invalid_interval"} do
        context "given a request with invalid interval specified" do
            it "fails with a 400 message" do
                 expect{test_client.create_forecast_session('TestRuby','01-22-2013','02-22-2013','sales','seconds')}.to raise_error{ |error|
                    expect(error).to be_a(NexosisApi::HttpException)
                    expect(error.code).to eql(400)
                    expect(error.message).to include("The value 'seconds' is not valid")
                 }
            end
        end
    end

    describe "#estimate_forecast_session",:vcr => {:cassette_name => "estimate_forecast_weekly"} do
        context "given a weekly forecast request" do
            it "estimates the weekly period" do
                #30 day span of time is only ~4 forecast requests, resulting in smaller estimate
                actual = test_client.estimate_forecast_session('TestRuby','01-22-2013','02-22-2013','sales', NexosisApi::TimeInterval::WEEK)
                expect(actual.cost).to eql('0.44 USD')
            end
        end
    end

    describe "#estimate_impact_session",:vcr => {:cassette_name => "estimate_impact_weekly"} do
        context "given a weekly impact request" do
            it "estimates the weekly period" do
                #30 day span of time is only ~4 forecast requests, resulting in smaller estimate
                actual = test_client.estimate_impact_session('TestRuby','05-01-2014','05-10-2014', 'test event','sales', NexosisApi::TimeInterval::WEEK)
                expect(actual.cost).to eql('0.13 USD')
            end
        end
    end

    describe "#list_sessions",:vcr => {:cassette_name => "list_sessions_pagesize"} do
        context "given a page size" do
            it "should return lte that size" do
                actual = test_client.list_sessions({},0,5)
                expect(actual).to be_a(Array)
                expect(actual.size).to eql(5)                
            end
        end
    end

    describe "#list_sessions",:vcr => {:cassette_name => "list_sessions_paged"} do
        context "given a page number" do
            it "should return next result set" do
                both = test_client.list_sessions({},0,2)
                id1 = both[0].sessionId
                id2 = both[1].sessionId
                pageOne = test_client.list_sessions({},0,1)
                expect(pageOne[0].sessionId).to eql(id1)
                pageTwo = test_client.list_sessions({},1,1)
                expect(pageTwo[0].sessionId).to eql(id2)
            end
        end
    end

     describe "#create_forecast_session", :vcr => {:cassette_name => "create_forecast_session_numericmeasure"} do
        context "given a metadata specification with measure" do
            it "executes a session with measure datatype" do
                columns = []
                columns << NexosisApi::DatasetColumn.new('transactions',{ "dataType" => NexosisApi::ColumnType::NUMERICMEASURE, "role" => NexosisApi::ColumnRole::FEATURE })
                actual  = test_client.create_forecast_session("TestRuby",'2013-07-18','2013-08-28',"sales",'day', columns)
                expect(actual).to be_a(NexosisApi::SessionResponse)
                expect(actual.column_metadata[2].type).to eql(NexosisApi::ColumnType::NUMERICMEASURE)
                expect(actual.column_metadata[2].imputation).to eql('mean')
                expect(actual.column_metadata[2].aggregation).to eql('mean')
            end
        end
    end
end