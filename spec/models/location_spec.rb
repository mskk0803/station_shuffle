require 'rails_helper'

RSpec.describe Location, type: :model do
  describe "バリデーションが有効な場合" do
    it "有効" do
      location = build(:location)
      expect(location).to be_valid
    end
  end

  describe "無効な場合" do
    it "緯度が無いときは無効" do
      location = build(:location, latitude: nil)
      expect(location).not_to be_valid
    end

    it "経度が無いときは無効" do
      location = build(:location, longitude: nil)
      expect(location).not_to be_valid
    end

    it "半径が無いときは無効" do
      location = build(:location, radius: nil)
      expect(location).not_to be_valid
    end

    it "緯度と経度が数値でない場合は無効" do
      location = build(:location, latitude: "緯度", longitude: "経度")
      expect(location).not_to be_valid
    end

    it "半径が数値でないときは無効" do
      location = build(:location, radius: "半径")
      expect(location).not_to be_valid
    end

    it "半径が1000未満だと無効" do
      location = build(:location, radius: 999)
      expect(location).not_to be_valid
    end

    it "半径が6000より大きいと無効" do
      location = build(:location, radius: 5001)
      expect(location).not_to be_valid
    end
  end

  describe "駅取得" do
    describe "#get_stations" do
      it "駅を取得できる" do
        location = build(:location)

        # モックの駅データ（フェイクデータ）
        fake_station_data = [
          double("Spot", name: "清瀬駅", lat: 35.7720582 , lng: 139.5198932)
        ]

        # GooglePlaces::Clientのspotsメソッドをスタブ
        client_instance = instance_double(GooglePlaces::Client)
        allow(GooglePlaces::Client).to receive(:new).and_return(client_instance)
        allow(client_instance).to receive(:spots).and_return(fake_station_data)

        stations = location.get_stations

        expect(stations.size).to eq(1)
        expect(stations.first.name).to eq("清瀬駅")
      end

      it "駅が見つからない場合は空配列を返す" do
        location = build(:location, latitude: 0, longitude: 0)

        client_instance = instance_double(GooglePlaces::Client)
        allow(GooglePlaces::Client).to receive(:new).and_return(client_instance)
        allow(client_instance).to receive(:spots).and_return([])

        stations = location.get_stations
        expect(stations).to eq([])
      end
    end
  end

  describe '.distance' do
    it '正しい距離（km）を返す（例：東京駅〜品川駅）' do
      tokyo_lat, tokyo_lng = 35.681236, 139.767125
      shinagawa_lat, shinagawa_lng = 35.628471, 139.73876

      distance = Location.distance(tokyo_lat, tokyo_lng, shinagawa_lat, shinagawa_lng)

      expect(distance).to be_within(0.1).of(6.4)
    end

    it '同じ地点なら距離は0' do
      distance = Location.distance(35.0, 135.0, 35.0, 135.0)
      expect(distance).to eq(0)
    end
  end

  describe '.moving_invalid?' do
    it '秒速8㎞を超えると不正と判定' do
      pre_time = Time.current
      current_time = pre_time + 1
      distance = 8.1 # km
      expect(Location.moving_invalid?(pre_time, current_time, distance)).to be true
    end

    it '秒速8㎞ちょうどは不正と判定される' do
      pre_time = Time.current
      current_time = pre_time + 1
      distance = 8.0 # km
      expect(Location.moving_invalid?(pre_time, current_time, distance)).to be true
    end

    it '秒速8㎞より小さい場合不正と判定されない' do
      pre_time = Time.current
      current_time = pre_time + 1
      distance = 7.9 # km
      expect(Location.moving_invalid?(pre_time, current_time, distance)).to be false
    end
  end

  describe '.in_radius?' do
    it '300m未満ならtrueを返す' do
      expect(Location.in_radius?(0.2)).to be true
    end

    it '300mちょうどならfalseを返す' do
      expect(Location.in_radius?(0.3)).to be false
    end

    it '300m超過ならfalseを返す' do
      expect(Location.in_radius?(0.31)).to be false
    end
  end
end
