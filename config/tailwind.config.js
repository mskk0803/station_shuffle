const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/helpers/**/*.rb',
    './app/javascript/**/*.js',
    './app/views/**/*.{erb,haml,html,slim}'
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [
    require("daisyui")
    // require('@tailwindcss/forms'),
    // require('@tailwindcss/typography'),
    // require('@tailwindcss/container-queries'),
  ],
  daisyui: {
    themes:[
      {
        "mytheme": {
          "primary": "#50C878",     // エメラルドグリーン（爽やかなメインカラー）
          "base-100": "#50C878",    // 優しいグリーン系ベース（背景色）
  
          "secondary": "#A5B4FC",   // 薄いブルー系（ボタンやリンクのアクセント）
          "accent": "#F59E0B",      // 暖かいオレンジ系（通知や強調に使用）
  
          "neutral": "#374151",     // 落ち着いたグレー（本文やナビゲーションに）
          "text": "#1F2937",        // 黒に近いグレー（本文の文字色）
  
          "info": "#3ABFF8",        // 情報系青
          "success": "#36D399",     // 成功系緑
          "warning": "#FBBD23",     // 警告系オレンジ
          "error": "#F87272",       // エラー系赤
  
          "btn-text": "#ffffff",    // ボタンの文字色は白に設定
          "btn-accent": "#50C878",  // ボタンのアクセントカラーにメインカラーを使用
          "btn-primary": "#50C878", // ボタンのメインカラーにメインカラーを使用
          "btn-secondary": "#A5B4FC", // セカンダリボタンに淡いブルーを使用
  
          // アクティブ状態のボタンやリンクのスタイル
          "btn-active": "#388E3C", // アクティブなボタンの背景色（少し暗いグリーン）
          "link-active": "#F59E0B", // アクティブなリンクの色（アクセントカラーのオレンジ）
          "link-hover": "#50C878",  // リンクホバー時の色（メインカラー）
          "link-focus": "#F59E0B",  // フォーカス時のリンク色（オレンジ）
  
          // アクティブ状態のリンクにアイコンなどがある場合
          "link-icon-active": "#F59E0B", // アイコン付きリンクのアクティブ状態
          "active-focus": "#F59E0B" // アクティブ状態のボタンやリンクにフォーカスがあった時のカラー
        }
      },
      "light"
    ]
  }
}
