require 'tk'

class LinearSearchApp
  def initialize
    # --- データ初期化 ---
    @data = [12, 45, 7, 23, 56, 89, 34, 90, 67, 11]
    @search_type = TkVariable.new('normal') # デフォルトの探索アルゴリズム

    # --- 画面（ルートウィンドウ）の構築 ---
    @root = TkRoot.new do
      title "線形探索アルゴリズム デモ"
      geometry "500x400"
    end

    setup_ui
    update_data_display
  end

  private

  # UIコンポーネントの配置
  def setup_ui
    # タイトルラベル
    TkLabel.new(@root, text: "線形探索 (Linear Search) シミュレーター", font: "Helvetica 14 bold").pack(pady: 10)

    # 配列表示エリア
    @data_frame = TkFrame.new(@root).pack(pady: 10)
    @label_widgets = [] # 視覚化用のラベル配列

    # アルゴリズム選択（ラジオボタン）
    radio_frame = TkLabelFrame.new(@root, text: " 探索アルゴリズムの選択 ").pack(pady: 10, fill: 'x', padx: 20)
    TkRadioButton.new(radio_frame, text: "通常の線形探索", variable: @search_type, value: 'normal').pack(anchor: 'w', padx: 10)
    TkRadioButton.new(radio_frame, text: "番兵付き線形探索", variable: @search_type, value: 'sentinel').pack(anchor: 'w', padx: 10)
    TkRadioButton.new(radio_frame, text: "自己組織化探索 (先頭移動法)", variable: @search_type, value: 'mtf').pack(anchor: 'w', padx: 10)

    # 入力エリア
    input_frame = TkFrame.new(@root).pack(pady: 10)
    TkLabel.new(input_frame, text: "探す数値: ").pack(side: 'left')
    @entry = TkEntry.new(input_frame, width: 5).pack(side: 'left', padx: 5)
    
    # 実行ボタン
    TkButton.new(input_frame, text: "探索開始", command: proc { start_search }).pack(side: 'left', padx: 5)

    # 結果表示ラベル
    @result_label = TkLabel.new(@root, text: "数値を入力して「探索開始」を押してください。", font: "Helvetica 11").pack(pady: 15)
  end

  # 現在の配列の状態を画面に描画（更新）する
  def update_data_display
    # 既存のラベルを削除
    @label_widgets.each(&:destroy)
    @label_widgets.clear

    # 配列を格子状に並べて表示
    @data.each_with_index do |val, _idx|
      lbl = TkLabel.new(@data_frame, text: val.to_s, width: 4, height: 2, 
                        relief: 'groove', bg: 'white', font: 'Courier 12 bold')
      lbl.pack(side: 'left', padx: 2)
      @label_widgets << lbl
    end
  end

  # 探索ボタンが押された時の処理
  def start_search
    target_str = @entry.get.strip
    if target_str.empty? || !target_str.match?(/^\d+$/)
      @result_label.text = "エラー: 正しい数値を入力してください。"
      return
    end

    target = target_str.to_i
    
    # いったん色をリセット
    reset_label_colors

    # 選択されたアルゴリズムに応じて処理を分岐
    case @search_type.value
    when 'normal'
      run_normal_search(target)
    when 'sentinel'
      run_sentinel_search(target)
    when 'mtf'
      run_move_to_front_search(target)
    end
  end

  # ラベルの色を白に戻す
  def reset_label_colors
    @label_widgets.each { |lbl| lbl.bg('white') }
  end

  # アニメーション効果（ウェイト）のためのメソッド
  def step_delay
    @root.update # 画面を描画更新
    sleep(0.4)    # 0.4秒待機（挙動を見やすくするため）
  end

  # 1. 通常の線形探索
  def run_normal_search(target)
    @result_label.text = "通常の線形探索を開始..."
    found_index = nil

    @data.each_with_index do |val, idx|
      @label_widgets[idx].bg('yellow') # 現在チェック中
      step_delay

      if val == target
        @label_widgets[idx].bg('lightgreen') # 発見！
        found_index = idx
        break
      else
        @label_widgets[idx].bg('lightgray') # 違ったのでグレーアウト
      end
    end

    if found_index
      @result_label.text = "【結果】インデックス #{found_index} で見つかりました！(比較回数: #{found_index + 1}回)"
    else
      @result_label.text = "【結果】見つかりませんでした。(比較回数: #{@data.size}回)"
    end
  end

  # 2. 番兵付き線形探索
  def run_sentinel_search(target)
    @result_label.text = "番兵付き線形探索を開始 (末尾に番兵を追加)..."
    
    # データを一時的にコピーして番兵(target)を末尾に追加
    temp_data = @data.dup
    temp_data << target

    # 画面に番兵用の一時的なラベルを追加
    sentinel_lbl = TkLabel.new(@data_frame, text: "#{target}\n(番兵)", width: 6, height: 2, 
                               relief: 'solid', bg: 'lightblue', font: 'Courier 10 bold')
    sentinel_lbl.pack(side: 'left', padx: 5)
    @root.update

    idx = 0
    while temp_data[idx] != target
      if idx < @label_widgets.size
        @label_widgets[idx].bg('lightgray')
      end
      idx += 1
      step_delay
    end

    # ループを抜けた後、それが「本物」か「番兵」かを最後に1回だけ判定する
    if idx < @data.size
      @label_widgets[idx].bg('lightgreen')
      @result_label.text = "【結果】インデックス #{idx} で見つかりました！"
    else
      sentinel_lbl.bg('orange')
      @result_label.text = "【結果】番兵に到達したため、データ内に存在しません。"
    end

    # 1.5秒後に番兵ラベルを消去して画面を戻す
    @root.after(1500) do
      sentinel_lbl.destroy
      reset_label_colors
    end
  end

  # 3. 自己組織化探索 (先頭移動法)
  def run_move_to_front_search(target)
    @result_label.text = "自己組織化探索 (先頭移動法) を開始..."
    found_index = nil

    @data.each_with_index do |val, idx|
      @label_widgets[idx].bg('yellow')
      step_delay

      if val == target
        @label_widgets[idx].bg('lightgreen')
        found_index = idx
        break
      else
        @label_widgets[idx].bg('lightgray')
      end
    end

    if found_index
      @result_label.text = "【結果】インデックス #{found_index} で発見！先頭に移動します。"
      step_delay

      # 配列の要素を先頭に移動させる
      element = @data.delete_at(found_index)
      @data.unshift(element)

      # 画面の並び順を更新
      update_data_display
      @label_widgets[0].bg('lightgreen') # 移動した先頭をハイライト
    else
      @result_label.text = "【結果】見つかりませんでした。(配列は変更されません)"
    end
  end
end

# アプリケーションの起動
LinearSearchApp.new
Tk.mainloop
