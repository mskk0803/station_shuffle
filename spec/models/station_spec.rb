require 'rails_helper'

RSpec.describe Station, type: :model do
  describe "入力値が有効な場合" do
    it "有効" do
      station = build(:station)
      expect(station).to be_valid
    end
  end

  describe "無効な場合" do
    it "駅名がないときは無効" do
      station = build(:station, name: nil)
      expect(station).not_to be_valid
    end

    it "緯度が無いときは無効" do
      station = build(:station, latitude: nil)
      expect(station).not_to be_valid
    end

    it "経度が無いときは無効" do
      station = build(:station, longitude: nil)
      expect(station).not_to be_valid
    end
  end
end
