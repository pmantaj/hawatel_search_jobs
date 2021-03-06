require 'spec_helper'

describe HawatelSearchJobs::Client do
  context 'with default settings' do
    it '#new' do
      client = HawatelSearchJobs::Client.new
      HawatelSearchJobs::Client::APIS.each do |api|
        expect(client.instance_variable_get("@#{api.downcase.to_s}")[:activated]).to eq(false)
      end
    end

    it 'multiple client objects do not have shared variables ' do
      client_first = HawatelSearchJobs::Client.new
      client_second = HawatelSearchJobs::Client.new

      HawatelSearchJobs::Client::APIS.each do |api|
        client_first.instance_variable_get("@#{api.downcase.to_s}")[:activated] = true
        client_second.instance_variable_get("@#{api.downcase.to_s}")[:activated] = false
      end

      HawatelSearchJobs::Client::APIS.each do |api|
        expect(client_first.instance_variable_get("@#{api.downcase.to_s}")[:activated]).to eq(true)
        expect(client_second.instance_variable_get("@#{api.downcase.to_s}")[:activated]).to eq(false)
      end
    end
  end

  context 'with custom settings' do
    before(:each) do
      HawatelSearchJobs.configure do |config|
        config.indeed[:activated] = false
        config.indeed[:publisher] = ''
        config.indeed[:page_size] = 10

        config.xing[:activated] = false
        config.xing[:consumer_key] = ''
        config.xing[:consumer_secret] = ''
        config.xing[:oauth_token] = ''
        config.xing[:oauth_token_secret] = ''
        config.xing[:page_size] = 60

        config.reed[:activated] = false
        config.reed[:clientid] = ''
        config.reed[:page_size] = 40

        config.careerbuilder[:activated]= false
        config.careerbuilder[:clientid] = ''
        config.careerbuilder[:page_size] = 80

        config.careerjet[:activated]   =true
        config.careerjet[:api]   = 'public.api.careerjet.net'
        config.careerjet[:page_size]   = 70

        config.upwork[:activated] = false
        config.upwork[:consumer_key]       = ''
        config.upwork[:consumer_secret]    = ''
        config.upwork[:oauth_token]        = ''
        config.upwork[:oauth_token_secret] = ''
        config.upwork[:page_size]          = 20

      end
    end

    let(:client) { HawatelSearchJobs::Client.new }

    it '#search valid data' do
      client.search_jobs({:keywords => 'ruby'})
      valid_jobs_table(client)
    end

    it '#search count method' do
      client.search_jobs({:keywords => 'ruby'})
      expect(client.count).to be_kind_of(Integer)
    end

    it '#search page size limit' do
      client.search_jobs({:keywords => 'ruby'})
      client.jobs_table.each do |provider, result|
        expect(result.jobs.count).to eq(HawatelSearchJobs.instance_variable_get("@#{provider.to_s}")[:page_size])
      end
    end

    it '#next valid data' do
      client.search_jobs({:keywords => 'ruby'})

      valid_page_number(0, client)
      valid_jobs_table(client)
      client.next

      valid_page_number(1, client)
      valid_jobs_table(client)
    end
  end

  private
  def valid_jobs_table(client)
    expect(client.jobs_table).not_to be_nil
    client.jobs_table.each do |provider, result|
      expect(result.totalResults).to be >= 0
    end
  end

  def valid_page_number(page, client)
    client.jobs_table.each do |provider, result|
      expect(result.page).to be == page
    end
  end
end