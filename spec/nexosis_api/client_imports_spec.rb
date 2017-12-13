require 'helper'

describe NexosisApi::Client::Imports do
  describe '#import_from_s3', :vcr => {:cassette_name => 'import_from_s3'} do
    context 'given a csv document in S3' do
      it 'returns an S3 response' do
        columns = []
        columns << NexosisApi::Column.new('timeStamp',{ 'dataType' => NexosisApi::ColumnType::DATE, 'role' => NexosisApi::ColumnRole::TIMESTAMP })
        columns << NexosisApi::Column.new('sales',{ 'dataType' => NexosisApi::ColumnType::NUMERIC, 'role' => NexosisApi::ColumnRole::TARGET })
        columns << NexosisApi::Column.new('transactions',{ 'dataType' => NexosisApi::ColumnType::NUMERIC, 'role' => NexosisApi::ColumnRole::NONE })
        actual  = test_client.import_from_s3('TestRuby_JsonImport', 'nexosis-sample-data', 'LocationA.csv', 'us-east-1', {}, columns) 
        expect(actual).to_not be_nil
        expect(actual).to be_a(NexosisApi::ImportsResponse)
        expect(actual.status).to eql('requested')
        expect(actual.column_metadata[1].role).to eql(NexosisApi::ColumnRole::TARGET)
        sleep 5
        begin
          test_client.remove_dataset('TestRuby_JsonImport', { cascade: true})
        rescue Exception
        end
      end
    end
  end

  describe '#retrieve_import', :vcr => {:cassette_name => 'retrieve_import'} do
    context 'given an active S3 import' do
      it 'returns an import response with status' do
        existing_imports = test_client.list_imports
        actual = test_client.retrieve_import existing_imports[0].import_id
        expect(actual).to_not be_nil
        expect(actual).to be_a(NexosisApi::ImportsResponse)
      end
    end
  end

  describe '#list_imports', :vcr => {:cassette_name => 'list_imports'} do
    context 'given some existing imports' do
      it 'returns list of all existing' do
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

  describe '#import_from_azure', vcr: { cassette_name: 'import_azure' } do
    context 'given a connection string' do
      it 'imports file from blob storage' do
        ds_name = 'AzureImportRuby'
        container = 'datatest'
        blob = 'mpg/auto-mpg.data.json'
        conn_string = "BlobEndpoint=#{ENV['AZURE_TEST_STORAGE_URI']};SharedAccessSignature=#{ENV['AZURE_TEST_TOKEN']}"
        response = test_client.import_from_azure(ds_name, conn_string, container, blob)
        loop do
          status_check = test_client.retrieve_import response.import_id
          break if (status_check.status == 'completed' || status_check.status == 'failed')
          sleep 5
        end
        dataset = test_client.list_datasets(ds_name)
        expect(dataset.length).to be > 0
        test_client.remove_dataset(ds_name)
      end
    end
  end

  describe '#import_from_url', vcr: { cassette_name: 'import_url' } do
    context 'given a url' do
      it 'imports file from endpoint' do
        ds_name = 'URLImportRuby'
        url = "#{ENV['AZURE_TEST_STORAGE_URI']}/datatest/mpg/auto-mpg.data.json#{ENV['AZURE_TEST_TOKEN']}"
        response = test_client.import_from_url(ds_name, url)
        loop do
          status_check = test_client.retrieve_import response.import_id
          break if (status_check.status == 'completed' || status_check.status == 'failed')
          sleep 5
        end
        dataset = test_client.list_datasets(ds_name)
        expect(dataset.length).to be > 0
        test_client.remove_dataset(ds_name)
      end
    end
  end

  describe '#import_from_secure_s3', vcr: { cassette_name: 'import_secure_s3' } do
    context 'given a private bucket and creds' do
      it 'imports file using creds' do
        ds_name = 'S3SecureImportRuby'
        bucket = 'nexosis-test'
        path = 'dummytest_keyed.csv'
        region = 'us-east-1'
        key = ENV['AWS_TEST_IAM_ACCESSKEY']
        secret = ENV['AWS_TEST_IAM_SECRETKEY']
        response = test_client.import_from_s3(ds_name,
                                              bucket,
                                              path,
                                              region,
                                              access_key_id: key, secret_access_key: secret)
        loop do
          status_check = test_client.retrieve_import response.import_id
          break if (status_check.status == 'completed' || status_check.status == 'failed')
          sleep 5
        end
        dataset = test_client.list_datasets(ds_name)
        expect(dataset.length).to be > 0
        test_client.remove_dataset(ds_name)
      end
    end
  end
end
