require 'json'
module NexosisApi
  class Client
    # Imports-based API operations
    #
    # @see http://docs.nexosis.com/
    module Imports

      # List all existing import requests
      #
      # @param dataset_name [String] optional name filter of dataset which was imported
      # @param page [int] page number for items in list
      # @param page_size [int] number of items in each page
      # @return [NexosisApi::PagedArray of NexosisApi::ImportsResponse]
      # @since 1.4 added paging parameters
      def list_imports(dataset_name = '', page = 0, page_size = 50)
        imports_url = '/imports'
        query = {
          dataSetName: dataset_name,
          page: page,
          pageSize: page_size
        }
        response = self.class.get(imports_url, headers: @headers, query: query)
        if (response.success?)
          NexosisApi::PagedArray.new(response.parsed_response,
                                     response.parsed_response['items']
                                     .map { |i| NexosisApi::ImportsResponse.new(i) })
        else
          raise HttpException.new("There was a problem getting the imports: #{response.code}.", "uploading dataset from s3 #{dataset_name}", response)
        end
      end

      # Import a file from AWS s3 as your dataset
      #
      # @param dataset_name [String] the name to give to the new dataset or existing dataset to which this data will be upserted
      # @param bucket_name [String] the AWS S3 bucket name in which the path will be found
      # @param path [String] the path within the bucket (usually file name)
      # @param region [String] the region in which your bucket exists. Defaults to us-east-1
      # @param credentials [Hash] :access_key_id and :secret_access_key for user with rights to read the target file.
      # @param column_metadata [Array of NexosisApi::Column] description of each column in target dataset. Optional.
      # @return [NexosisApi::ImportsResponse]
      # @see http://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region for information on region names
      # @note If credentials are provided they will be encrypted at the server, used once, and then removed from storage.
      def import_from_s3(dataset_name, bucket_name, path, region = 'us-east-1', credentials = {}, column_metadata = [])
        raise ArgumentError, 'dataset_name was not provided and is not optional ' unless dataset_name.to_s.empty? == false
        raise ArgumentError, 'bucket_name was not provided and is not optional ' unless bucket_name.to_s.empty? == false
        raise ArgumentError, 'path was not provided and is not optional ' unless path.to_s.empty? == false
        s3_import_url = '/imports/s3'
        column_json = Column.to_json(column_metadata)
        body = {
          'dataSetName' => dataset_name,
          'bucket' => bucket_name,
          'path' => path,
          'region' => region,
          'columns' => column_json
        }
        body['accessKeyId'] = credentials[:access_key_id] unless credentials[:access_key_id].nil?
        body['secretAccessKey'] = credentials[:secret_access_key] unless credentials[:secret_access_key].nil?
        response = self.class.post(s3_import_url, headers: @headers, body: body.to_json)
        raise HttpException.new("There was a problem importing from s3: #{response.code}.",
                                "uploading dataset from s3 #{dataset_name}",
                                response) unless response.success?
        NexosisApi::ImportsResponse.new(response.parsed_response)
      end

      # Get response back from import created previously. Presumably to check status.
      #
      # @param import_id [String] The id returned from a previous request to import
      # @return [NexosisApi::ImportsResponse]
      # @example get import
      #    NexosisApi.client.retrieve_import('740dca2a-b488-4322-887e-fa473b1caa54')
      def retrieve_import(import_id)
        raise ArgumentError, 'import_id was not provided and is not optional ' unless import_id.to_s.empty? == false
        imports_url = "/imports/#{import_id}"
        response = self.class.get(imports_url, headers: @headers)
        raise HttpException.new("There was a problem getting the import #{response.code}.",
                                "requesting an import #{import_id}", response) unless response.success?
        NexosisApi::ImportsResponse.new(response.parsed_response)
      end

      # Import a csv, json file (gzip'd or raw) from a Microsoft Azure storage blob
      #
      # @param dataset_name [String] the name to give to the new dataset or existing dataset to which this data will be upserted
      # @param connection_string [String] the azure blob storage connection string providing access to the file resource
      # @param container [String] the container in which the object is located.
      # @param blob_name [String] the name of the object to import, usually a file. Always csv or json content.
      # If folders have been used this will contain the full path within the container.
      # @param column_metadata [Array of NexosisApi::Column] description of each column in target dataset. Optional.
      # @return [NexosisApi::ImportsResponse]
      # @since 2.0.0
      # @note the connection string provided will be encrypted at the server, used once, and then removed from storage.
      def import_from_azure(dataset_name, connection_string, container, blob_name, column_metadata = [])
        raise ArgumentError, 'dataset_name was not provided and is not optional ' unless dataset_name.empty? == false
        raise ArgumentError, 'connection_string was not provided and is not optional ' unless connection_string.empty? == false
        raise ArgumentError, 'container was not provided and is not optional ' unless container.empty? == false
        raise ArgumentError, 'blob_name was not provided and is not optional ' unless blob_name.empty? == false
        azure_url = '/imports/azure'
        column_json = Column.to_json(column_metadata)
        body = {
          'dataSetName' => dataset_name,
          'connectionString' => connection_string,
          'container' => container,
          'blob' => blob_name,
          'columns' => column_json
        }
        response = self.class.post(azure_url, headers: @headers, body: body.to_json)
        raise HttpException.new("There was a problem importing from azure: #{response.code}.",
                                "uploading dataset from azure #{dataset_name}",
                                response) unless response.success?
        NexosisApi::ImportsResponse.new(response.parsed_response)
      end

      # Import a csv or json file directly from any avaiable and reachable public endpoint.
      #
      # @param dataset_name [String] the name to give to the new dataset or existing dataset to which this data will be upserted
      # @param url [String] the url indicating where to find the file resource to import
      # @param column_metadata [Array of NexosisApi::Column] description of each column in target dataset. Optional.
      # @param options [Hash] may provide basic auth credentials or a 'content-type' value to identify csv or json content.
      # @return [NexosisApi::ImportsResponse]
      # @note imports depend on file extensions, so use a content type indicator if json or csv cannot be inferred.
      # @note Urls protected by basic auth can be accessed if given a userid and password in options
      # @since 2.0.0
      def import_from_url(dataset_name, url, column_metadata = [], options = {})
        raise ArgumentError, 'dataset_name was not provided and is not optional ' unless dataset_name.empty? == false
        raise ArgumentError, 'url was not provided and is not optional ' unless url.empty? == false
        endpoint_url = '/imports/url'
        column_json = Column.to_json(column_metadata)
        body = {
          'dataSetName' => dataset_name,
          'url' => url,
          'columns' => column_json
        }
        response = self.class.post(endpoint_url, headers: @headers, body: body.to_json)
        raise HttpException.new("There was a problem importing from url: #{response.code}.",
                                "uploading dataset from #{url}",
                                response) unless response.success?
        NexosisApi::ImportsResponse.new(response.parsed_response)
      end
    end
  end
end
