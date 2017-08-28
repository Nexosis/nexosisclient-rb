require 'helper'

describe NexosisApi::Client::Imports do
    describe "#import_from_s3", :vcr => {:cassette_name => "import_from_s3"} do
        context "given a csv document in S3" do
            it "returns an S3 response" do
                columns = []
                columns << NexosisApi::Column.new('timeStamp',{ "dataType" => NexosisApi::ColumnType::DATE, "role" => NexosisApi::ColumnRole::TIMESTAMP })
                columns << NexosisApi::Column.new('sales',{ "dataType" => NexosisApi::ColumnType::NUMERIC, "role" => NexosisApi::ColumnRole::TARGET })
                columns << NexosisApi::Column.new('transactions',{ "dataType" => NexosisApi::ColumnType::NUMERIC, "role" => NexosisApi::ColumnRole::NONE })
                actual  = test_client.import_from_s3('TestRuby_Json', 'nexosis-sample-data', 'LocationA.csv', 'us-east-1', columns) 
                expect(actual).to_not be_nil
                expect(actual).to be_a(NexosisApi::ImportsResponse)
                expect(actual.status).to eql("requested")
                expect(actual.column_metadata[1].role).to eql(NexosisApi::ColumnRole::TARGET)
            end
        end
    end

    describe "#retrieve_import", :vcr => {:cassette_name => "retrieve_import"} do
        context "given an active S3 import" do
            it "returns an import response with status" do
               existing_imports = test_client.list_imports
               actual = test_client.retrieve_import existing_imports[0].import_id
               expect(actual).to_not be_nil
               expect(actual).to be_a(NexosisApi::ImportsResponse)
            end
        end
    end

    describe "#list_imports", :vcr => {:cassette_name => "list_imports"} do
        context "given some existing imports" do
            it "returns list of all existing" do
                actual = test_client.list_imports
                expect(actual).to_not be_nil
                expect(actual).to be_a(Array)
                expect(actual[0]).to be_a(NexosisApi::ImportsResponse)
            end
        end
    end

    describe '#import_from_s3' do
        context 'given no dataset_name' do
          it 'raises ArgumentError' do
            expect { test_client.import_from_s3 ''}.to raise_error { |error|
              expect(error).to be_a(ArgumentError)
           }
          end
        end
    end
    
    describe '#retrieve_import' do
        context 'given no import_id' do
          it 'raises ArgumentError' do
            expect { test_client.retrieve_import ''}.to raise_error { |error|
              expect(error).to be_a(ArgumentError)
           }
          end
        end
    end
end