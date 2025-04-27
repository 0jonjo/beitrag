require 'rails_helper'

RSpec.describe 'Posts Routes', type: :request do
  describe 'POST #create' do
    let(:user) { create(:user) }
    let(:valid_attributes) { { post: { title: 'Test Title', body: 'Test Body',
                              ip: '192.0.2.255', login: user.login } } }
    let(:invalid_attributes) { { post: { title: '', body: 'Test Body',
                              ip: '192.0.2.255', login: user.login } } }
    let(:guest_attributes) { { post: { title: 'Test Title', body: 'Test Body',
                              ip: '192.0.2.255', login: "without_login" } } }
    let(:json_response) { JSON.parse(response.body) }

    context 'with valid attributes' do
      context 'when user exists' do
        it 'creates a new post' do
          expect {
            post api_v1_posts_path, params: valid_attributes
          }.to change(Post, :count).by(1)
        end

        it 'returns a success response' do
          post api_v1_posts_path, params: valid_attributes, as: :json

          expect(response).to have_http_status(:created)
        end

        it 'returns the created post with the user' do
          post api_v1_posts_path, params: valid_attributes, as: :json

          expect(json_response['post']).to be_present
          expect(json_response['user']).to be_present
          expect(json_response['post']['user_id']).to eq(user.id)
        end
      end

      context 'when user does not exist' do
        it 'creates a new post with a guest user' do
          expect {
            post api_v1_posts_path, params: guest_attributes
          }.to change(Post, :count).by(1)
        end

        it 'returns a success response' do
          post api_v1_posts_path, params: guest_attributes, as: :json

          expect(response).to have_http_status(:created)
        end

        it 'returns the created post with a guest user' do
          post api_v1_posts_path, params: guest_attributes, as: :json

          expect(json_response['post']).to be_present
          expect(json_response['user']['login']).to eq(User.last.login)
        end
      end
    end

    context 'with invalid attributes' do
      it 'does not create a new post' do
        expect {
          post api_v1_posts_path, params: invalid_attributes
        }.not_to change(Post, :count)
      end

      it 'returns an unprocessable entity response' do
        post api_v1_posts_path, params: invalid_attributes, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'returns error messages' do
        post api_v1_posts_path, params: invalid_attributes, as: :json

        expect(json_response['errors']).to include("Title can't be blank")
      end
    end
  end

  describe 'GET #index' do
    let!(:posts) { create_list(:post, 5) }
    let(:limit) { 3 }
    let(:json_response) { JSON.parse(response.body) }

    before do
      create_list(:rating, 3, post: posts.first, value: 5)
      create_list(:rating, 2, post: posts.second, value: 4)
      create_list(:rating, 1, post: posts.third, value: 3)
      get api_v1_posts_path, params: { limit: limit }
    end

    it 'returns a list of posts' do
      expect(response).to have_http_status(:ok)
      expect(json_response.size).to eq(limit)
    end

    it 'returns the correct post attributes' do
      expect(json_response.first).to include('id', 'title', 'body', 'average_rating')
    end

    it 'returns the top-rated posts' do
      expect(json_response.count).to eq(limit)
      expect(json_response.first['id']).to eq(posts.first.id)
    end
  end

  describe 'GET #ips_authors' do
    let(:user1) { create(:user) }
    let(:user2) { create(:user) }
    let(:user3) { create(:user) }
    let(:shared_ip1) { "192.168.1.1" }
    let(:shared_ip2) { "192.168.1.2" }
    let(:unique_ip) { "192.168.1.3" }
    let(:json_response) { JSON.parse(response.body) }

    before do
      create(:post, user: user1, ip: shared_ip1)
      create(:post, user: user2, ip: shared_ip1)
      create(:post, user: user1, ip: shared_ip2)
      create(:post, user: user3, ip: shared_ip2)
      create(:post, user: user1, ip: unique_ip)

      get ips_authors_api_v1_posts_path
    end

    it 'returns a success response' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns IPs used by multiple users' do
      expect(json_response.size).to eq(2)
      expect(json_response.map { |item| item['ip'] }).to include(shared_ip1, shared_ip2)
    end

    it 'does not include IPs used by only one user' do
      expect(json_response.map { |item| item['ip'] }).not_to include(unique_ip)
    end

    it 'includes the correct user logins for each IP' do
      shared_ip1_record = json_response.find { |item| item['ip'] == shared_ip1 }
      shared_ip2_record = json_response.find { |item| item['ip'] == shared_ip2 }

      expect(shared_ip1_record['logins']).to include(user1.login, user2.login)
      expect(shared_ip2_record['logins']).to include(user1.login, user3.login)
    end
  end
end
