require 'rails_helper'

describe "SimiCheckWebservice" do

  describe ".get_all_comparisons" do
    context "any time called" do
      it "returns a response with code 200 and body containing all comparisons" do
        puts "Testing SimiCheck get all comparisons"
        response = SimiCheckWebService.get_all_comparisons()
        json_response = JSON.parse(response.body)
        expect(response.code).to eql(200)
        expect(json_response["comparisons"]).to be_truthy
      end
    end
  end

  describe ".new_comparison" do
    context "called with a comparison_name" do
      it "returns a response with code 200, and body containing the name and new id for this comparison" do
        puts "Testing SimiCheck new comparison"
        response = SimiCheckWebService.new_comparison('test new comparison')
        json_response = JSON.parse(response.body)
        comp_id = json_response["id"]
        expect(response.code).to eql(200)
        expect(json_response["id"]).to be_truthy
        SimiCheckWebService.delete_comparison(comp_id)
      end
    end
  end

  describe ".delete_comparison" do
    context "called with a comparison id" do
      it "returns a response with code 200" do
        puts "Testing SimiCheck delete comparison"
        response = SimiCheckWebService.new_comparison('test new comparison')
        json_response = JSON.parse(response.body)
        comp_id = json_response["id"]
        response = SimiCheckWebService.delete_comparison(comp_id)
        expect(response.code).to eql(200)
      end
    end
  end

  describe ".get_comparison_details" do
    context "called with a comparison id" do
      it "returns a response with code 200 and body containing info about the comparison" do
        puts "Testing SimiCheck get comparison details"
        response = SimiCheckWebService.new_comparison('test new comparison')
        json_response = JSON.parse(response.body)
        comp_id = json_response["id"]
        response = SimiCheckWebService.get_comparison_details(comp_id)
        json_response = JSON.parse(response.body)
        expect(response.code).to eql(200)
        expect(json_response["name"]).to be_truthy
        SimiCheckWebService.delete_comparison(comp_id)
      end
    end
  end

  describe ".update_comparison" do
    context "called with a new comparison name" do
      it "returns a response with code 200 and body containing info about the comparison" do
        puts "Testing SimiCheck update comparison"
        response = SimiCheckWebService.new_comparison('test new comparison')
        json_response = JSON.parse(response.body)
        comp_id = json_response["id"]
        response = SimiCheckWebService.update_comparison(comp_id, 'updated name')
        expect(response.code).to eql(200)
        SimiCheckWebService.delete_comparison(comp_id)
      end
    end
  end

  describe ".upload_file" do
    context "called with a comparison id and filepath" do
      it "returns a response with code 200 and body containing info about the file" do
        puts "Testing SimiCheck upload file to comparison"
        response = SimiCheckWebService.new_comparison('test new comparison')
        json_response = JSON.parse(response.body)
        comp_id = json_response["id"]
        test_upload_text = 'This is some sample text.'
        filepath = '/tmp/test_upload.txt'
        File.open(filepath, "w") { |file| file.write(test_upload_text) }
        response = SimiCheckWebService.upload_file(comp_id, filepath)
        File.delete(filepath) if File.exist?(filepath)
        expect(response.code).to eql(200)
        expect(json_response["id"]).to be_truthy
        SimiCheckWebService.delete_comparison(comp_id)
      end
    end
  end

  describe ".delete_files" do
    context "called with a comparison id and filenames to delete" do
      it "returns a response with code 200" do
        puts "Testing SimiCheck delete file from comparison"
        response = SimiCheckWebService.new_comparison('test new comparison')
        json_response = JSON.parse(response.body)
        comp_id = json_response["id"]
        test_upload_text = 'This is some sample text.'
        filename = 'test_upload.txt'
        filepath = '/tmp/test_upload.txt'
        File.open(filepath, "w") { |file| file.write(test_upload_text) }
        SimiCheckWebService.upload_file(comp_id, filepath)
        File.delete(filepath) if File.exist?(filepath)
        response = SimiCheckWebService.delete_files(comp_id, [filename])
        expect(response.code).to eql(200)
        SimiCheckWebService.delete_comparison(comp_id)
      end
    end
  end

  describe ".get_similarity_nxn" do
    context "called with a comparison id" do
      it "returns a response with code 200 and body containing info about the results" do
        puts "Testing SimiCheck get comparison results"
        response = SimiCheckWebService.new_comparison('test new comparison')
        json_response = JSON.parse(response.body)
        comp_id = json_response["id"]
        test_upload_text = 'This is some sample text.'
        filepath = '/tmp/test_upload.txt'
        File.open(filepath, "w") { |file| file.write(test_upload_text) }
        SimiCheckWebService.upload_file(comp_id, filepath)
        File.delete(filepath) if File.exist?(filepath)
        test_upload_text = 'This is some more sample text.'
        filepath = '/tmp/test_upload2.txt'
        File.open(filepath, "w") { |file| file.write(test_upload_text) }
        SimiCheckWebService.upload_file(comp_id, filepath)
        File.delete(filepath) if File.exist?(filepath)
        SimiCheckWebService.post_similarity_nxn(comp_id)
        while true
          begin
            response = SimiCheckWebService.get_similarity_nxn(comp_id)
            if response.code == 200
              break
            end
          rescue
            puts '   Waiting 30 seconds to check again for results...'
            sleep(30)
            next
          end
        end
        expect(response.code).to eql(200)
        json_response = JSON.parse(response.body)
        expect(json_response["similarities"]).to be_truthy
        SimiCheckWebService.delete_comparison(comp_id)
      end
    end
  end

  describe ".visualize_similarity" do
    context "called with a comparison id" do
      it "returns a response with code 200 and body containing the visualize url path" do
        puts "Testing SimiCheck get visualize similarity link"
        response = SimiCheckWebService.new_comparison('test new comparison')
        json_response = JSON.parse(response.body)
        comp_id = json_response["id"]
        test_upload_text = 'This is some sample text.'
        filepath = '/tmp/test_upload.txt'
        File.open(filepath, "w") { |file| file.write(test_upload_text) }
        SimiCheckWebService.upload_file(comp_id, filepath)
        File.delete(filepath) if File.exist?(filepath)
        test_upload_text = 'This is some more sample text.'
        filepath = '/tmp/test_upload2.txt'
        File.open(filepath, "w") { |file| file.write(test_upload_text) }
        SimiCheckWebService.upload_file(comp_id, filepath)
        File.delete(filepath) if File.exist?(filepath)
        SimiCheckWebService.post_similarity_nxn(comp_id)
        while true
          begin
            response = SimiCheckWebService.get_similarity_nxn(comp_id)
            if response.code == 200
              break
            end
          rescue
            puts '   Waiting 30 seconds to check again for results...'
            sleep(30)
            next
          end
        end
        response = SimiCheckWebService.visualize_similarity(comp_id)
        expect(response.code).to eql(200)
        expect(response.body).to be_truthy
        SimiCheckWebService.delete_comparison(comp_id)
      end
    end
  end

  describe ".visualize_comparison" do
    context "called with a comparison id and two filenames" do
      it "returns a response with code 200 and body containing the visualize url path" do
        puts "Testing SimiCheck get visualize similarity link"
        response = SimiCheckWebService.new_comparison('test new comparison')
        json_response = JSON.parse(response.body)
        comp_id = json_response["id"]
        test_upload_text = 'This is some sample text.'
        filepath = '/tmp/test_upload.txt'
        File.open(filepath, "w") { |file| file.write(test_upload_text) }
        file1_id = JSON.parse(SimiCheckWebService.upload_file(comp_id, filepath).body)["id"]
        File.delete(filepath) if File.exist?(filepath)
        test_upload_text = 'This is some more sample text.'
        filepath = '/tmp/test_upload2.txt'
        File.open(filepath, "w") { |file| file.write(test_upload_text) }
        file2_id = JSON.parse(SimiCheckWebService.upload_file(comp_id, filepath).body)["id"]
        File.delete(filepath) if File.exist?(filepath)
        SimiCheckWebService.post_similarity_nxn(comp_id)
        while true
          begin
            response = SimiCheckWebService.get_similarity_nxn(comp_id)
            if response.code == 200
              break
            end
          rescue
            puts '   Waiting 30 seconds to check again for results...'
            sleep(30)
            next
          end
        end
        response = SimiCheckWebService.visualize_comparison(comp_id, file1_id, file2_id)
        expect(response.code).to eql(200)
        expect(response.body).to be_truthy
        SimiCheckWebService.delete_comparison(comp_id)
      end
    end
  end


end
