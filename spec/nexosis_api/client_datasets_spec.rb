require 'helper'
require 'csv'
require 'json'

describe NexosisApi::Client::Datasets do
    describe "#create_dataset_json", :vcr => {:cassette_name => "create_dataset_json"} do
        context "given a dataset json hash" do
            it "returns a dataset summary" do
                data = JSON.load(File.open('spec/fixtures/sampledata.json'))
                actual  = test_client.create_dataset_json 'TestRuby_Json', data 
                expect(actual).to be_a(NexosisApi::DatasetSummary)
            end
        end
    end

    describe "#create_dataset_json", :vcr => {:cassette_name => "create_dataset_roles"} do
        context "given a json dataset with metadata" do
            it "returns a dataset summary" do
                data = JSON.load(File.open('spec/fixtures/featureroledata.json'))
                actual  = test_client.create_dataset_json 'TestRuby_JsonMetadata', data 
                expect(actual).to be_a(NexosisApi::DatasetSummary)
                expect(actual.column_metadata[0].role).to eql(:target)
                expect(actual.column_metadata[2].role).to eql(:feature)
                test_client.remove_dataset('TestRuby_JsonMetadata', {"cascade" => true})
            end
        end
    end

    describe "#create_dataset_csv",:vcr => {:cassette_name => "create_dataset_csv"} do
        context "given a dataset csv file" do
            it "returns a dataset summary" do
                data = CSV.open('spec/fixtures/sampledata.csv','rb', headers: true)
                actual  = test_client.create_dataset_csv 'TestRuby_CSV', data 
                expect(actual).to be_a(NexosisApi::DatasetSummary)
                test_client.remove_dataset('TestRuby_CSV', {"cascade" => true})
            end
        end
    end

    describe "#list_datasets",:vcr => {:cassette_name => "list_datasets_all"} do 
        context "given existing saved datasets" do
            it "returns a list dataset summaries for all existing" do
                actual  = test_client.list_datasets
                expect(actual).to be_a(Array)
                actual.each { |ds| expect(ds).to be_a(NexosisApi::DatasetSummary) }
            end
        end
    end

    describe "#list_datasets",:vcr => {:cassette_name => "list_datasets_partial"} do
        context "given existing saved datasets" do
            it "returns a list dataset summaries containing the partial name" do
                actual  = test_client.list_datasets "Ruby"
                expect(actual).to be_a(Array)
                actual.each { |ds| 
                    expect(ds).to be_a(NexosisApi::DatasetSummary)
                    expect(ds.dataset_name).to include("Ruby")
                }
            end
        end
    end

    describe "#get_dataset",:vcr => {:cassette_name => "get_datasets_data"} do
        context "given an existing saved dataset" do 
            it "returns the dataset data" do
                dataset_name = "TestRuby"
                page_number = 0
                page_size = 20
                query_options = {}
                actual = test_client.get_dataset dataset_name, page_number, page_size, query_options
                expect(actual).to be_a(NexosisApi::DatasetData)
                expect(actual.data.length).to eql(20)
            end
        end
    end

    describe "#get_dataset",:vcr => {:cassette_name => "get_datasets_data_filtered"} do
        context "given an existing saved dataset with dates in range" do 
            it "returns the dataset data on for the given range" do
                start_date = DateTime.strptime('2014-01-01', '%Y-%m-%d')
                end_date = DateTime.strptime('2014-03-30', '%Y-%m-%d')
                dataset_name = "TestRuby"
                page_number = 0
                page_size = 20
                query_options = { :start_date => start_date, :end_date => end_date }
                actual = test_client.get_dataset dataset_name, page_number, page_size, query_options
                expect(actual).to be_a(NexosisApi::DatasetData)
                expect(actual.data.length).to eql(20)
                actual.data.each do |d|
                    entry_date = DateTime.parse(d["timeStamp"])
                    expect(entry_date).to be_between(start_date,end_date).inclusive
                end
            end
        end
    end

    describe "#get_dataset_csv", :vcr => {:cassette_name => "get_datasets_data_csv"} do
        context "given an existing saved dataset" do
            it "returns the dataset in CSV format" do
                actual = test_client.get_dataset_csv "TestRuby"
                expect(actual).not_to be_nil
                csv_format = CSV.parse(actual,{:headers=>true})
                expect(csv_format.length).to be > 0
                expect(csv_format).to be_a(CSV::Table)
            end
        end
    end

    describe "#remove_dataset", :vcr => {:cassette_name => "remove_dataset_all"} do
        context "given an existing saved dataset" do 
            it "removes the entire dataset" do
                test_client.create_dataset_csv('ToRemove',"timestamp,foo\r\n1-1-2017,223.33\r\n1-2-2017,345.31")
                test_client.remove_dataset('ToRemove')
                datasets = test_client.list_datasets
                expect(datasets.any?{|v|v == "ToRemove"}).to eql(false)
            end
        end
    end
    
    describe "#remove_dataset", :vcr => {:cassette_name => "remove_dataset_partial"} do
        context "given an existing saved dataset" do 
            it "removes part of the dataset" do
                test_client.create_dataset_csv('ToRemove',"timestamp,foo\r\n1-1-2017,223.33\r\n1-2-2017,345.31")
                test_client.remove_dataset('ToRemove', { :start_date => '1-2-2017' })
                actual = test_client.get_dataset 'ToRemove'
                expect(actual.data.length).to eql(1) 
            end
        end
    end

    describe "#remove_dataset", :vcr => {:cassette_name => "remove_dataset_cascade"} do
        context "given an existing saved dataset with completed sessions and cascade true" do 
            it "removes the dataset and the sessions" do
                test_client.create_dataset_csv('ToRemove',"timestamp,foo\r\n1-1-2017,223.33\r\n1-2-2017,345.31")
                session = test_client.create_forecast_session('ToRemove','1-3-2017','1-4-2017','foo')
                loop do
                    status_check = test_client.get_session session.sessionId
                    break if (status_check.status == "completed" || status_check.status == "failed")
                    sleep 5
                end
                
                test_client.remove_dataset('ToRemove', { :cascade => true })
                expect{test_client.get_dataset 'ToRemove'}.to raise_error { |error|
                    expect(error.code).to eql(404)
                }
                expect{test_client.get_session session.sessionId}.to raise_error {|error|
                    expect(error.code).to eql(404)
                }
            end
        end
    end

    describe "#create_dataset_csv", :vcr => {:cassette_name => "create_csv_notimestamp"} do
        context "given a csv with no distinct timestamp column" do 
            it "creates the dataset and infers column" do
                data = CSV.open('spec/fixtures/notimestamp.csv','rb', headers: true)
                actual  = test_client.create_dataset_csv 'TestRuby_NoTimestamp', data
                expect(actual).to be_a(NexosisApi::DatasetSummary)
                expect(actual.column_metadata[1].role).to eql(:timestamp)
                test_client.remove_dataset('TestRuby_NoTimestamp', {"cascade" => true})
            end
        end
    end
end