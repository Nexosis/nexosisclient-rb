require 'helper'
require 'csv'

describe NexosisApi::Client::Sessions do
    describe "#create_forecast_session", :vcr => {:cassette_name => "create_forecast_dataset"} do
        context "given an existing dataset name" do
            it "returns a started session" do
                actual = test_client.create_forecast_session('TestRuby','01-22-2017','02-22-2017','sales')
                expect(actual).to be_instance_of(NexosisApi::SessionResponse)
                expect(actual.type).to eql('forecast')
            end
        end
    end

    describe "#estimate_forecast_session", :vcr  => {:cassette_name => "estimate_forecast_session"} do
        context "given an existing dataset name" do
            it "returns a session response with cost" do
                actual = test_client.estimate_forecast_session('TestRuby','01-22-2017','02-22-2017','sales')
                expect(actual.cost).to eql('3.1 USD')
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
                expect(actual.cost).to eql('0.9 USD')
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

    describe "#create_forecast_session_csv", :vcr  => {:cassette_name => "create_forecast_session_csv"} do
        context "given a csv file as a dataset with headers true" do
            it "returns a session response" do
                file = CSV.open('spec/fixtures/sampledata.csv','rb', headers: true)
                actual = test_client.create_forecast_session_csv(file,'2014-05-20','2014-05-21','sales')
                expect(actual.type).to eql('forecast')
            end
        end
    end

    describe "#create_forecast_session_csv", :vcr  => {:cassette_name => "create_forecast_session_csv_noheader"} do
        context "given a csv file as a dataset with headers false" do
            it "returns a session response" do
                file = CSV.open('spec/fixtures/sampledata.csv','rb')
                actual = test_client.create_forecast_session_csv(file,'2014-05-20','2014-06-20','sales')
                expect(actual.type).to eql('forecast')
            end
        end
    end

    describe "#create_forecast_session_csv", :vcr  => {:cassette_name => "create_forecast_session_csv_fail"} do
        context "given csv content that isn't illegal but isn't properly formatted'" do
            it "throws an HttpException error" do
                file = CSV.open('spec/fixtures/malformeddata.csv','rb')
                expect { actual = test_client.create_forecast_session_csv('timestamp,foo\r\n2014-05-19,65.25','2014-05-20','2014-05-21','sales')}.to raise_error { |error|
                    expect(error).to be_a(NexosisApi::HttpException)
                }
            end
        end
    end

    describe "#create_forecast_session_csv", :vcr  => {:cassette_name => "create_forecast_session_csv_fail"} do
        context "given csv content that isn't really csv" do
            it "throws an MalformedCSVError error" do
                file = CSV.open('spec/fixtures/malformeddata.csv','rb')
                expect { actual = test_client.create_forecast_session_csv(file,'2014-05-20','2014-06-20','sales')}.to raise_error { |error|
                    expect(error).to be_a(CSV::MalformedCSVError)
                }
            end
        end
    end

    describe "#create_forecast_session_data", :vcr  => {:cassette_name => "create_forecast_session_data"} do
        context "given a json data formatted for the api" do  
            it "returns a session response" do
                file_content = IO.read('spec/fixtures/sampledata.json', mode: 'rb')
                actual = test_client.create_forecast_session_data(file_content,'2017-01-06','2017-01-10','sales')
                expect(actual).to be_instance_of(NexosisApi::SessionResponse)
                expect(actual.type).to eql('forecast')
            end
        end    
    end

    describe "#create_impact_session_data", :vcr => {:cassette_name => "create_impact_session_data"}  do
        context "given a json data formatted for the api" do  
            it "returns a session response" do
                file_content = IO.read('spec/fixtures/sampledata.json',mode: 'rb')
                actual = test_client.create_impact_session_data(file_content,'2013-05-10','2013-05-19','test event','sales')
                expect(actual).to be_instance_of(NexosisApi::SessionResponse)
                expect(actual.type).to eql('impact')
                test_client.remove_dataset(actual.dataSetName,{"cascade"=>true})
            end
        end    
    end

    describe "#get_session_results", :vcr  => {:cassette_name => "get_session_results"} do
        context "given the id of an completed session" do 
            it "returns the results of the session analysis" do
                session = test_client.create_forecast_session_csv("timestamp,foo\r\n1-1-2017,334.22\r\n1-2-2017,533.87",'1-3-2017','1-4-2017','foo')
                loop do
                    status_check = test_client.get_session session.sessionId
                    break if (status_check.status == "completed" || status_check.status == "failed")
                    sleep 5
                end
                begin
                    actual = test_client.get_session_results session.sessionId
                    expect(actual).to be_a(NexosisApi::SessionResult)
                    expect(actual.data).not_to be_empty
                ensure
                    test_client.remove_dataset(session.dataSetName, {:cascade => true})
                end
            end
        end
    end

    #TODO: this isn't a good test until we can page and know how many exist
    # describe "#list_sessions", :vcr  => {:cassette_name => "list_sessions"} do
    #     context "given a request without a query" do
    #         it "returns an array of all sessions" do
    #             actual = test_client.list_sessions
    #         end
    #     end
    # end
    
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
                new_session = test_client.create_forecast_session_csv("timestamp,sales\r\n01-01-2017,234.45\r\n01-02-2017,343.22",'01-03-2017','01-05-2017','sales')
                existing_dataset = new_session.dataSetName
                test_client.remove_sessions :dataset_name => existing_dataset
                expect{test_client.get_session(new_session.sessionId)}.to raise_error{ |error|
                    expect(error).to be_a(NexosisApi::HttpException)
                    expect(error.code).to eql(404)
                }
            end
        end
    end

    describe "#create_forecast_session_data", :vcr => {:cassette_name => "create_forecast_session_features"} do
        context "given a json dataset with metadata" do
            it "executes a session with a feature identified" do
                data = JSON.load(File.open('spec/fixtures/featureroledata.json'))
                actual  = test_client.create_forecast_session_data(data,'2013-07-18','2013-08-28')
                expect(actual).to be_a(NexosisApi::SessionResponse)
                expect(actual.targetColumn).to eql('sales')
                test_client.remove_dataset(actual.dataSetName,{"cascade"=>true})
            end
        end
    end

    describe "#create_forecast_session", :vcr => {:cassette_name => "create_session_no_dataset_404"} do
        context "given a dataset name that does not exist" do
            it "fails with a 404 http message" do
                 expect{test_client.create_forecast_session('IDontExist','01-22-2017','02-22-2017','sales')}.to raise_error{ |error|
                    expect(error).to be_a(NexosisApi::HttpException)
                    expect(error.code).to eql(404)
                 }
            end
        end
    end

    describe "#create_forecast_session", :vcr => {:cassette_name => "create_session_invalid_interval"} do
        context "given a request with invalid interval specified" do
            it "fails with a 400 message" do
                 expect{test_client.create_forecast_session('TestRuby','01-22-2017','02-22-2017','sales','seconds')}.to raise_error{ |error|
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
                actual = test_client.estimate_forecast_session('TestRuby','01-22-2017','02-22-2017','sales', NexosisApi::TimeInterval::WEEK)
                expect(actual.cost).to eql('0.442857142857143 USD')
            end
        end
    end

    describe "#estimate_impact_session",:vcr => {:cassette_name => "estimate_impact_weekly"} do
        context "given a weekly impact request" do
            it "estimates the weekly period" do
                #30 day span of time is only ~4 forecast requests, resulting in smaller estimate
                actual = test_client.estimate_impact_session('TestRuby','05-01-2014','05-10-2014', 'test event','sales', NexosisApi::TimeInterval::WEEK)
                expect(actual.cost).to eql('0.128571428571429 USD')
            end
        end
    end
end