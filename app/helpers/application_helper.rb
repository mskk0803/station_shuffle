module ApplicationHelper
  # 参考URL：https://qiita.com/suzuyu0115/items/7f83f84b640640b7e498
  def default_meta_tags
    {
      site: "えきぷらっと",
      title: "えきぷらっと",
      reverse: true,
      separator: "|",
      description: "今日はどこにお出かけしよう？駅探検系SNS",
      keywords: "お出かけ,駅",   # キーワードを「,」区切りで設定する
      canonical: request.original_url,   # 優先するurlを指定する
      noindex: ! Rails.env.production?,
      icon: [                    # favicon、apple用アイコンを指定する
        { href: image_url("favicon.ico") }
      ],
      og: {
        site_name: "えきぷらっと",
        title: "えきぷらっと",
        description: "今日はどこにお出かけしよう？駅探検系SNS",
        type: "website",
        url: request.original_url,
        image: image_url("ogp.png"),
        locale: "ja_JP"
      },
      twitter: {
        card: "summary_large_image",
        site: "@sakupimskk"
      },
      fb: {
        app_id: ""
      }
    }
  end
end
