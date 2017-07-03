require 'helper'

describe NexosisApi::Client::Imports do
    describe "#import_from_s3", :vcr => {:cassette_name => "import_from_s3"} do
        context "given a csv document in S3" do
            it "returns an S3 response" do
                columns = []
                columns << NexosisApi::DatasetColumn.new('timeStamp',{ "dataType" => NexosisApi::ColumnType::DATE, "role" => NexosisApi::ColumnRole::TIMESTAMP })
                columns << NexosisApi::DatasetColumn.new('sales',{ "dataType" => NexosisApi::ColumnType::NUMERIC, "role" => NexosisApi::ColumnRole::TARGET })
                columns << NexosisApi::DatasetColumn.new('transactions',{ "dataType" => NexosisApi::ColumnType::NUMERIC, "role" => NexosisApi::ColumnRole::NONE })
                actual  = test_client.import_from_s3('TestRuby_Json', 'nexosis-sample-data', 'LocationA.csv', 'us-east-1', columns) 
                expect(actual).to_not be_nil
                expect(actual).to be_a(NexosisApi::S3Response)
                expect(actual.status).to eql("requested")
                expect(actual.column_metadata[1].role).to eql(NexosisApi::ColumnRole::TARGET)
            end
        end
    end
end