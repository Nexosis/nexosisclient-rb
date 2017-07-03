require 'json'
module NexosisApi
	class Client
		# Imports-based API operations
		#
		# @see http://docs.nexosis.com/
		module Imports
            # Import a file from AWS s3 as your dataset
            #
            # @param dataset_name [String] the name to give to the new dataset or existing dataset to which this data will be upserted
            # @param bucket_name [String] the AWS S3 bucket name in which the path will be found
            # @param path [String] the path within the bucket (usually file name)
            # @param region [String] the region in which your bucket exists. Defaults to us-east-1
            # @param column_metadata [Array of NexosisApi::DatasetColumn] description of each column in target dataset. Optional.
            # @return [NexosisApi::S3Response]
            # @see http://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region for information on region names
            def import_from_s3(dataset_name, bucket_name, path, region = "us-east-1", column_metadata = [])
                raise ArgumentError "dataset_name was not provided and is not optional " unless dataset_name.to_s.empty? == false
                raise ArgumentError "bucket_name was not provided and is not optional " unless bucket_name.to_s.empty? == false
                raise ArgumentError "path was not provided and is not optional " unless path.to_s.empty? == false
                
                s3_import_url = "/imports/s3"
                column_json = DatasetColumn.to_json(column_metadata)
                body = {
                    "dataSetName" => dataset_name,
                    "bucket" => bucket_name,
                    "path" => path,
                    "region" => region,
                    "columns" => column_json
                }
                response = self.class.post(s3_import_url, :headers => @headers, :body => body.to_json)
                if(response.success?)
                    NexosisApi::S3Response.new(response.parsed_response)
                else
                   raise HttpException.new("There was a problem uploading the dataset: #{response.code}.", "uploading dataset from s3 #{dataset_name}" ,response)
			    end
            end

            # Get s3 response back from import created previously. Presumably to check status.
            #
            # @param import_id [String] The id returned from a previous request to import
            # @return [NexosisApi::S3Response]
            # @example get S3 import
            #    NexosisApi.client.retrieve_import('740dca2a-b488-4322-887e-fa473b1caa54')
            def retrieve_import(import_id)
                raise ArgumentError "import_id was not provided and is not optional " unless import_id.to_s.empty? == false
                imports_url = "/imports/#{import_id}"
                response = self.class.get(imports_url, :headers => @headers)
                if(response.success?)
                    NexosisApi::S3Response.new(response.parsed_response)
                else
                   raise HttpException.new("There was a problem uploading the dataset: #{response.code}.", "uploading dataset from s3 #{dataset_name}" ,response)
			    end
            end
        end
    end
end