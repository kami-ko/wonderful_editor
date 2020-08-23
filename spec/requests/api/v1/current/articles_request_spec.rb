require "rails_helper"

RSpec.describe "Api::V1::Current::Articles", type: :request do
  describe "GET /api/v1/current/articles" do
    let!(:article1) { create(:article, :with_published, user: current_user, updated_at: 1.day.ago) }
    let!(:article2) { create(:article, :with_published, user: current_user, updated_at: 2.days.ago) }
    let!(:article3) { create(:article, :with_published, user: current_user) }

    let(:current_user) { create(:user) }
    context "ログインしている場合" do
      subject { get(api_v1_current_articles_path, headers: headers) }

      let(:headers) { current_user.create_new_auth_token }
      it "ログインしているユーザーの投稿一覧が取得できる" do
        subject
        res = JSON.parse(response.body)
        expect(res.length).to eq 3
        expect(res.map {|d| d["id"] }).to eq [article3.id, article1.id, article2.id]
        expect(res[0]["user"]["id"]).to eq current_user.id
        expect(res[0]["user"]["name"]).to eq current_user.name
        expect(res[0]["user"]["email"]).to eq current_user.email
        expect(res[0].keys).to eq ["id", "title", "status", "updated_at", "user"]
        expect(res[0]["user"].keys).to eq ["id", "name", "email"]
        expect(response).to have_http_status(:ok)
      end
    end

    context "ログインしていない場合" do
      subject { get(api_v1_current_articles_path) }

      it "ログインしているユーザーの投稿一覧が取得できない" do
        subject
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
