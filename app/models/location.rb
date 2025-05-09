class Location
  # DBには保存しないけどバリデーションように必要な処理
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :latitude, :longitude, :radius

  validates :latitude, presence: true, numericality: true
  validates :longitude, presence: true, numericality: true
  validates :radius, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1000, less_than_or_equal_to: 5000 }


  # APIで駅を取得する
  def get_stations
    client = GooglePlaces::Client.new(ENV["GOOGLE_API_KEY"])

    # 3回まで取得できる
    # 必要になったら書く
    # 一番最後のnextpagetokenを取得し、client.spots_by_pagetoken(token)で対応する
    stations_data = client.spots(self.latitude,
                                  self.longitude,
                                  types: "train_station",
                                  language: "ja",
                                  radius: self.radius)

    # 取得できなかった場合は空の配列を返す
    if stations_data.blank?
      return []
    end

    # 　Sationクラスの配列を作成
    stations = stations_data.map do |s|
      Station.new(name: s.name, latitude: s.lat, longitude: s.lng)
    end
    stations
  end

  # 移動距離計算関数
  def self.distance(lat1, lon1, lat2, lon2)
    # 地球の半径 (km)
    earth_radius = 6378.137

    rad = ->(deg) { deg * Math::PI / 180 }

    d_lat = rad.call(lat2 - lat1)
    d_lon = rad.call(lon2 - lon1)

    a = Math.sin(d_lat / 2)**2 +
        Math.cos(rad.call(lat1)) * Math.cos(rad.call(lat2)) * Math.sin(d_lon / 2)**2

    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))

    # 距離を計算
    earth_radius * c
  end

  # 不正移動検知関数
  # trueなら不正移動
  def self.moving_invalid?(pre_time, current_time, distance)
    # 時間差
    time_diff = (current_time - pre_time).to_i
    # 移動速度
    distance_m = distance * 1000
    speed = distance_m / time_diff

    # 新幹線は秒速80m
    speed >= 80
  end

  # 目的地からの半径判定(300m以内でtrue)
  def self.in_radius?(distance)
    if distance < 0.3
      true
    else
      false
    end
  end
end
