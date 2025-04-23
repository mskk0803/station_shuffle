class Location

  # DBには保存しないけどバリデーションように必要な処理
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :latitude, :longitude, :radius

  validates :latitude, presence: true, numericality: true
  validates :longitude, presence: true, numericality: true
  validates :radius, presence: true, numericality: { only_integer: true, greater_than: 1000, less_than: 5000 }


  # APIで駅を取得する
  def get_stations
    client = GooglePlaces::Client.new(ENV["GOOGLE_API_KEY"])

    # 3回まで取得できる
    # 必要になったら書く
    # 一番最後のnextpagetokenを取得し、client.spots_by_pagetoken(token)で対応する
    stations_data = client.spots( self.latitude,
                                  self.longitude,
                                  types: "train_station",
                                  language: "ja",
                                  radius: self.radius )

    # 取得できなかった場合は空の配列を返す
    if stations_data.blank?
      return []
    end

    #　Sationクラスの配列を作成
    stations = stations_data.map do |s|
      Station.new( name: s.name, latitude: s.lat, longitude: s.lng )
    end
    stations
  end
end
