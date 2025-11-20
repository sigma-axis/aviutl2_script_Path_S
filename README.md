# パス描画 AviUtl ExEdit2 スクリプト

折れ線やベジェ曲線で図形を描画したり，その図形を利用したフィルタ効果をかける AivUtl ExEdit 2 のスクリプトです．

[ダウンロードはこちら．](https://github.com/sigma-axis/aviutl2_script_Path_S/releases) \[紹介動画準備中．\]

次が追加されます:

1.  [パス図形σ](#パス図形σ) (オブジェクト)
1.  [ラインσ](#ラインσ) (オブジェクト)
1.  [スパイラルσ](#スパイラルσ) (オブジェクト)
1.  [アローσ](#アローσ) (オブジェクト)
1.  [パスマスクσ](#パスマスクσ) (フィルタ効果)
1.  [パスマスク(ライン)σ](#パスマスクラインσ) (フィルタ効果)
1.  [パス部分フィルタσ](#パス部分フィルタσ) (フィルタ効果)
1.  [パスに沿って配置σ](#パスに沿って配置σ) (フィルタ効果)

<img width="960" height="540" alt="Overview of objects of this script" src="https://github.com/user-attachments/assets/57cc741b-9d50-4f68-a30a-d0608a6ba11c" />
<img width="960" height="540" alt="Overview of effects of this script" src="https://github.com/user-attachments/assets/1bf5cc4b-013f-4027-a01a-36847e10db24" />

- <details>
  <summary>元画像出典 (クリックで表示):</summary>

  1.  https://www.pexels.com/photo/assorted-color-kittens-45170
  1.  https://www.pexels.com/photo/assorted-color-house-facade-in-park-534124
  </details>

##  動作要件

- AviUtl ExEdit2

  http://spring-fragrance.mints.ne.jp/aviutl

  - `beta20` で動作確認済み．

## 導入方法

以下のフォルダのいずれかに `@Path_S.obj2`, `@Path_S.anm2`, `Path_S.lua` の 3 つのファイルをコピーしてください．

1.  スクリプトフォルダ
    - AviUtl2 のメニューの「その他」 :arrow_right: 「アプリケーションデータ」 :arrow_right: 「スクリプトフォルダ」で表示されます．
1.  (1) のフォルダにある任意の名前のフォルダ

- AviUtl2 のウィンドウにドラッグ&ドロップする方法での導入はできません．

##  スクリプトの種類

4 つのオブジェクトと 4 つのフィルタ効果が追加されます．

- 追加メニュー内の分類は「オブジェクト追加メニューの設定」の「ラベル」項目で変更できます．

### パス図形σ

パスに沿ったラインと，パス内を塗りつぶした図形を描画するオブジェクトです．

[パラメタの説明 :arrow_down:](#パス図形σのパラメタ) [共通のパラメタの説明 :arrow_down:](#共通の設定項目)

<img width="640" height="480" alt="Image of manipulating figure paths" src="https://github.com/user-attachments/assets/8fd01b02-daed-4ccf-ba51-0a040b4feb73" />
<img width="960" height="720" alt="Image of path strokes" src="https://github.com/user-attachments/assets/9059a77c-f2af-40d4-bbe2-8a1d61c99a05" />

- 初期状態だと「オブジェクトを追加」メニューの「Path_S :arrow_right: 図形」に「パス図形σ@Path_S」が追加されています．

### ラインσ

波線やジグザグ線など，よく使われるパターンのライン形状を描画するオブジェクトです．

[パラメタの説明 :arrow_down:](#ラインσのパラメタ) [共通のパラメタの説明 :arrow_down:](#共通の設定項目)

<img width="840" height="360" alt="Image of kinds of curves" src="https://github.com/user-attachments/assets/cf053f16-5abe-421d-8492-7497aef98e8d" />

- 初期状態だと「オブジェクトを追加」メニューの「Path_S :arrow_right: 図形」に「ラインσ@Path_S」が追加されています．

### スパイラルσ

渦巻の形のラインを描画するオブジェクトです．

[パラメタの説明 :arrow_down:](#スパイラルσのパラメタ) [共通のパラメタの説明 :arrow_down:](#共通の設定項目)

<img width="480" height="320" alt="Image of two kinds of spirals" src="https://github.com/user-attachments/assets/bfd8010a-8911-4fa6-b59f-1c2222c3da37" />

- 初期状態だと「オブジェクトを追加」メニューの「Path_S :arrow_right: 図形」に「スパイラルσ@Path_S」が追加されています．

### アローσ

パスに沿ったラインと先端図形を配置して，矢印の形を描画するオブジェクトです．

[パラメタの説明 :arrow_down:](#アローσのパラメタ) [共通のパラメタの説明 :arrow_down:](#共通の設定項目)

<img width="408" height="320" alt="Image of arrows with different placements of heads" src="https://github.com/user-attachments/assets/05c4cf9a-18fc-4535-87b6-aa2792b7f287" />

- 初期状態だと「オブジェクトを追加」メニューの「Path_S :arrow_right: 図形」に「アローσ@Path_S」が追加されています．

### パスマスクσ

パスで囲った範囲で画像を切り抜くフィルタ効果です．

[パラメタの説明 :arrow_down:](#パスマスクσ--パスマスクラインσ--パス部分フィルタσのパラメタ) [共通のパラメタの説明 :arrow_down:](#共通の設定項目)

<img width="640" height="480" alt="An image clipped by the inner part of a path" src="https://github.com/user-attachments/assets/02d94745-4678-4b7d-8f78-aeefca2edea6" />

- 初期状態だと「フィルタ効果を追加」メニューの「Path_S :arrow_right: クリッピング」に「パスマスクσ@Path_S」が追加されています．

### パスマスク(ライン)σ

パスの通ったライン上の画像を切り抜くフィルタ効果です．

[パラメタの説明 :arrow_down:](#パスマスクσ--パスマスクラインσ--パス部分フィルタσのパラメタ) [共通のパラメタの説明 :arrow_down:](#共通の設定項目)

<img width="640" height="480" alt="An image clipped by the stroke of a path" src="https://github.com/user-attachments/assets/21b6fe1e-c4b8-4d25-9ab5-6f0ed1e640ce" />

- 初期状態だと「フィルタ効果を追加」メニューの「Path_S :arrow_right: クリッピング」に「パスマスク(ライン)σ@Path_S」が追加されています．

### パス部分フィルタσ

パスで囲った範囲のみに，後続のフィルタ効果を適用するフィルタ効果です．

[パラメタの説明 :arrow_down:](#パスマスクσ--パスマスクラインσ--パス部分フィルタσのパラメタ) [共通のパラメタの説明 :arrow_down:](#共通の設定項目)

<img width="800" height="540" alt="An image that only a specific area is blurred and monochromed" src="https://github.com/user-attachments/assets/c37f44be-5f8b-414e-9a66-0d295fd63d5e" />

- 初期状態だと「フィルタ効果を追加」メニューの「Path_S :arrow_right: 加工」に「パス部分フィルタσ@Path_S」が追加されています．

### パスに沿って配置σ

パスに沿ってオブジェクトを配置するフィルタ効果です．個別オブジェクトでも間隔を空けて配置できます．

[パラメタの説明 :arrow_down:](#パスに沿って配置σのパラメタ) [共通のパラメタの説明 :arrow_down:](#共通の設定項目)

<img width="880" height="440" alt="Charcters of a text arrayed on a path" src="https://github.com/user-attachments/assets/58acd121-7966-4352-a9b5-960a9b76921d" />

- 初期状態だと「フィルタ効果を追加」メニューの「Path_S :arrow_right: 配置」に「パスに沿って配置σ@Path_S」が追加されています．

##  パラメタの説明

追加されるオブジェクトやフィルタ効果には一部，共通した設定項目があります．

それに加えて各オブジェクトやフィルタごとに固有の項目もあります．

### 共通の設定項目

####  頂点数

パスに含まれる "頂点" の個数を指定します．

1.  [「線タイプ」](#線タイプ)が `折れ線`，`補間移動` の場合 :arrow_right: 指定する点の個数がそのまま "頂点" の数．
1.  「線タイプ」が `2次ベジェ曲線`，`3次ベジェ曲線` の場合 :arrow_right: 制御点を除いた点の個数が "頂点" の数．

最小値は 2 (主に線を描画するもの) または 3 (主にパス内部を描画するもの), 初期値は 4.

####  線タイプ

パスの曲線の形状を指定します．

| 線タイプ | 例 | 備考 |
|:---:|:---:|:---|
| `折れ線` | <img width="360" height="256" alt="An example of straight paths" src="https://github.com/user-attachments/assets/194f2213-9d25-44e6-a710-fbea72aa4f09" /> |  |
| `補間移動` | <img width="360" height="256" alt="An example of interpolated path" src="https://github.com/user-attachments/assets/9c5d575d-0211-4d6d-9fa7-0f6bd605c5e9" /> | トラックバー移動方法の「補間移動」と同じ計算式． |
| `2次ベジェ曲線` | <img width="360" height="256" alt="An example of quadratic Bezier paths" src="https://github.com/user-attachments/assets/96fb023e-2243-4b0e-b3d4-db04d3745da5" /> | |
| `3次ベジェ曲線` | <img width="360" height="256" alt="An example of cubic Bezier paths" src="https://github.com/user-attachments/assets/a3563699-19e5-4ab8-9267-613989b88fa7" /> |初期値． |

初期値は `3次ベジェ曲線`.

####  点リスト

アンカーで操作した点がここに記録されます．基本的に手入力による設定は想定していません．

この項目をコピーして，[「頂点数」](#頂点数)[「線タイプ」](#線タイプ)も合わせると，同じパスを別オブジェクト・フィルタ効果で再現できます．

####  曲線精度

曲線を描画する際，一旦折れ線で近似しますが，その近似精度を指定します．指定した数値分のピクセル数以下の距離間隔の折れ線で近似します．

最小値は 1, 最大値は 128, 初期値は 8.

####  ぼかし幅

パスで囲った領域や，ライン部分のアンチエイリアスの幅を指定します．

最小値は 0, 最大値は 1000, 初期値は 1.

####  ライン幅

*ラインを描画するタイプのスクリプトでの設定です．*

ラインの幅をピクセル単位で指定します．

最小値は 0, 最大値は 1000, 初期値は 5.

####  ループ

*ラインを描画するタイプのスクリプトでの設定です．*

ラインをループ形状にするか，別々の2点を端点にするかを選びます．

####  開始位置, 終了位置

*ラインを描画するタイプのスクリプトでの設定です．*

ライン描画の開始位置と終了位置を，ライン全体の長さに対する % 単位で指定します．

- $\text{開始位置}>\text{終了位置}$ だとラインを描画しません．
- [「ループ」](#ループ)が ON の場合，0 % を下回った分はラインの終了点から，100 % を上回った分はラインの開始点からカウントされます．

最小値は -200, 最大値は 200, 初期値は「開始位置」が 0, 「終了位置」が 100.

####  端の形状

*ラインを描画するタイプのスクリプトでの設定です．*

ラインの端点の形状を指定します．[「ループ」](#ループ)が OFF の場合のみ有効です．

| 端の形状 | 例 |
|:---:|:---:|
| `円` | <img width="320" height="320" alt="Image of rounded endpoint" src="https://github.com/user-attachments/assets/0100b898-afe5-4b8a-b3eb-8ea5d6e30ce8" /> |
| `四角` | <img width="320" height="320" alt="Image of square endpoint" src="https://github.com/user-attachments/assets/f20cba23-64bd-472b-89ae-84ce36f0724f" /> |

初期値は `円`.

> [!NOTE]
> [「破線パターン」](#破線パターン-破線周期補正-破線位置)の途切れ目では，この設定によらず `円` に相当する形状になります．

####  破線パターン, 破線周期補正, 破線位置

*ラインを描画するタイプのスクリプトでの設定です．*

ラインを破線として描画できます．

1.  「破線パターン」でパターンを指定します．

    奇数個目の数値が実線部分，偶数個目が空白部分の長さで，それぞれピクセル単位で指定します．

    例:

    - `100,0` :arrow_right: 通常の実線 (初期値).
    - `80,40` :arrow_right: 「80 ピクセルの実線 + 40 ピクセルの空白」の繰り返しパターン．
    - `80,40,1,40` :arrow_right: 「80 ピクセルの実線 + 40 ピクセルの空白 + 1 ピクセルの実線 + 40 ピクセルの空白」の繰り返しパターン．

    初期値は `100,0`. 指定できる数値の個数は最大で 256 個までです．

1.  「破線周期補正」は[「ループ」](#ループ)が ON の場合のみ有効です．破線パターンの周期を，ループの長さの整数分の1倍になるように微調整します．

    初期値は ON.

1.  「破線位置」は破線パターンの開始位置を，ライン開始点からのピクセル単位で指定します．

    最小値は -4000, 最大値は 4000, 初期値は 0.

####  追加幅 / 塗り追加幅

*パス内部を塗りつぶすタイプのスクリプトでの設定です．*

パスで塗りつぶす範囲を指定ピクセル数だけ膨張させます．

最小値は 0, 最大値は 1000, 初期値は 0.

####  範囲 / 塗り範囲

*パス内部を塗りつぶすタイプのスクリプトでの設定です．*

パス内部の判定基準を指定します．

| 範囲 | 例 |
|:---:|:---:|
| `内側` | <img width="240" height="240" alt="Image of inner fill mode" src="https://github.com/user-attachments/assets/01ec1000-7812-4205-be59-ebb7f45623ae" /> |
| `奇偶` | <img width="240" height="240" alt="Image of parity fill mode" src="https://github.com/user-attachments/assets/e759daeb-ab71-4fc7-901b-e4f932dcfd44" /> |
| `内側反転` | <img width="240" height="240" alt="Image of inverted inner fill mode" src="https://github.com/user-attachments/assets/9e831812-8204-4455-915e-fc61764b6073" /> |
| `奇偶反転` | <img width="240" height="240" alt="Image of inverted parity fill mode" src="https://github.com/user-attachments/assets/5c1f8c26-27dc-40a0-a86d-a013f1d1a1e0" /> |

- 「反転」の系統は，[「追加幅」](#追加幅--塗り追加幅)での膨張の方向にも影響します．

初期値は `内側`.

####  ランダム周期, ランダム振幅, ランダム固定端, ランダムシード

*オブジェクト生成のスクリプトでのみの設定です．*

パスにランダムさを加えます．

1.  「ランダム周期」で指定したピクセル数ごとにパス上の点を分割し，その分割した両端をランダムに動かします．数値が小さいほどギザギザした，細かく動いたパスになります．

    最小値は 4, 最大値は 1024, 初期値は 32.

1.  「ランダム振幅」は，ランダムで点を移動する最大距離を指定します．0 だと乱数の影響はありません．

    最小値は 0, 最大値は 1024, 初期値は 0.

1.  「ランダム固定端」が ON のとき，ラインの開始点と終了点は乱数の影響を受けません．

    初期値はスクリプトによって異なります．

1.  「ランダムシード」は乱数のシードを指定します．

    - 正の (正確には非負の) シードだと同じシードでも別オブジェクトだと別の乱数．
    - 負のシードだと，同じシードなら別オブジェクトでも同じ乱数．

    整数値で指定，最小値は -65536, 最大値は 65535, 初期値は 10000.


### パス図形σのパラメタ

<img width="500" height="842" alt="Image of GUI of Figure" src="https://github.com/user-attachments/assets/4f09f33e-65cc-44e9-b9b6-d77a5c250e33" />

####  ライン色, ライン透明度

図形のライン部分の色と透明度を指定します．

1.  「ライン色」の初期値は `808080` (50% の灰色).
1.  「ライン透明度」は % 単位で指定，最小値は 0, 最大値は 100, 初期値は 0 (完全不透明).

####  塗り色, 塗り透明度

図形内部の塗りつぶしの色と透明度を指定します．

1.  「塗り色」の初期値は `ffffff` (白).
1.  「塗り透明度」は % 単位で指定，最小値は 0, 最大値は 100, 初期値は 0 (完全不透明).


### ラインσのパラメタ

<img width="500" height="598" alt="Image of GUI of Curve" src="https://github.com/user-attachments/assets/6dd02ab8-572c-4cc1-8e53-36e3795f8629" />

####  終点X, 終点Y

ラインの終点の X, Y 座標を指定します (始点はオブジェクトの標準描画等の指定座標です).

ピクセル単位で指定，最小値は -4000, 最大値は 4000, 初期値は $(256, 0)$.

####  色

ラインの色を指定します．

初期値は `ffffff` (白).

####  形状

ラインの形状を指定します．全て周期関数になっていて，周期や位相，振幅は[「周期」「周期位置」「振幅」](#周期-周期位置-振幅)で調整できます．

| 形状 | 式 |
|:---:|:---|
| `直線` | $y=0$ |
| `正弦波` | $y=\cos 2\pi x$  |
| `三角波` | $y=2\left\lvert 2\langle x \rangle - 1\right\rvert - 1$  |
| `矩形波` | $$ y=\begin{cases} +1 & \left(\langle x \rangle < \frac{1}{2}\right) \\\ -1 & (\text{otherwise}) \end{cases} $$ |
| `のこぎり波` | $y=1 - 2 \langle x \rangle$ |
- ここに $\langle x \rangle = x - \lfloor x \rfloor$ は $x$ の小数部分．

初期値は `正弦波`.

####  周期, 周期位置, 振幅

ラインの周期関数としての，周期や位相，波としての振幅を指定します．

1.  「周期」はピクセル単位で指定，最小値は 4, 最大値は 1024, 初期値は 64.
1.  「周期位置」は位相を調整します．開始点からのピクセル数で初期位相の点を指定します．

    最小値は -4000, 最大値は 4000, 初期値は 0.

1.  「振幅」は波としての振幅をピクセル単位で指定します．

    最小値は 0, 最大値は 1024, 初期値は 32.


### スパイラルσのパラメタ

<img width="500" height="668" alt="Image of GUI of Spiral" src="https://github.com/user-attachments/assets/80139642-b9c0-4cba-98e2-a322f62a11db" />

####  傾き

螺旋の半径に対する角度の移動量の比率を調整します．厳密な解釈は[「形状」](#形状-1)によって異なりますが，数値 (の絶対値) が大きいほど回転回数が大きくなります．負になると回転方向が逆転します．

| 形状 | 解釈 |
|:---:|:---|
| `アルキメデス螺旋` | 半径が 1024 ピクセル進むごとに回る周回数． |
| `対数螺旋` | 中心からの半直線と交わる接線の傾き (正接). |

最小値は -200, 最大値は 200, 初期値は 10.

####  色

螺旋図形の色を指定します．

初期値は `ffffff` (白).

####  形状

螺旋の種類を指定します．

| 形状 | 例 |
|:---:|:---|
| `アルキメデス螺旋` | <img width="240" height="240" alt="Archimedean Spiral" src="https://github.com/user-attachments/assets/a9a55709-a623-4bf1-a33f-339fc44de4e3" /> |
| `対数螺旋` | <img width="240" height="240" alt="Logarithmic Spiral" src="https://github.com/user-attachments/assets/2c3f425a-56b0-40a4-889b-ab64b8452216" /> |

初期値は `対数螺旋`.

####  開始半径, 終了半径

描画する螺旋の範囲を，中心からの距離の範囲でピクセル単位で指定します．

「開始半径」と「終了半径」のどちらが大きくても構いませんが，[破線パターン](#破線パターン-破線周期補正-破線位置)の開始点は「開始半径」の位置が基準になります．

最小値は 0, 最大値は 2000, 初期値は，「開始半径」が 0, 「終了半径」が 256.

####  回転

螺旋図形全体を回転させます．

角度を時計回りの度数法で指定，最小値は -720, 最大値は 720, 初期値は 0.

####  ずれX, ずれY

螺旋の半径が大きくなるにつれて中心をずらすことができます．半径が 256 ピクセル進むごとにずれる量をピクセル単位で指定します．

マウス操作でアンカーを動かして指定もできます．

最小値は -4000, 最大値は 4000, 初期値は 0.

### アローσのパラメタ

<img width="500" height="842" alt="Image of GUI of Arrow" src="https://github.com/user-attachments/assets/68520881-ca71-4826-b7c3-6b1dd603ae28" />

####  色

矢印図形の色を指定します．

初期値は `ffffff` (白).

####  矢じり配置

矢じり部分の配置を指定します．

| 矢じり配置 | 例 |
|:---:|:---:|
| `なし` | <img width="240" height="160" alt="Example of no arrowheads" src="https://github.com/user-attachments/assets/6daf1471-8611-4638-b423-dc1f8da017d5" /> |
| `終点` | <img width="240" height="160" alt="Example of arrowhead on the end" src="https://github.com/user-attachments/assets/56c92338-d48b-4a09-abad-14f2b2349a76" /> |
| `両方` | <img width="240" height="160" alt="Example of two arrowheads with the same directions" src="https://github.com/user-attachments/assets/fd51402e-c87e-4cde-a8ba-aa918691328a" /> |
| `双方向` | <img width="240" height="160" alt="Example of two arrowheads with the opposite directions" src="https://github.com/user-attachments/assets/aeccddf4-4647-4625-b0d7-061adbfaa72d" /> |

初期値は `終点`.

####  矢じり図形

矢じり部分の形状を図形の種類から選びます．SVG ファイルを指定することもできます．

初期値は `三角形`.

####  矢じりサイズ, 矢じり幅

矢じり部分の大きさを指定します．「矢じりサイズ」で全体の大きさを，「矢じり幅」で横幅部分の比率をそれぞれ指定します．

1.  「矢じりサイズ」はピクセル単位で指定，最小値は 0, 最大値は 1024, 初期値は 32.
1.  「矢じり幅」は % 単位で指定，最小値は 0, 最大値は 800, 初期値は 100.

####  矢じり中心, 矢じり角度

矢じり部分の基準位置や回転中心，回転角度を微調整します．

1.  「矢じり中心」は基準位置を，元図形の縦方向の位置から % 単位で指定します．0% で中央, -100% で図形の最下端，+100% で再上端の指定です．

    最小値は -100, 最大値は 100, 初期値は -50.

1.  「矢じり角度」は矢じり部分の向きを調整できます．

    時計回りの度数法で指定，最小値は -720, 最大値は 720, 初期値は 0.

####  矢じり位置

矢じり部分のライン上の位置を調整します．ライン全体の長さからの割合で % 単位で指定，通常の基準位置から，正の値でラインの終点に向かって，負の値で始点に向かって動きます．

最小値は -100, 最大値は 100, 初期値は 0.


### パスマスクσ / パスマスク(ライン)σ / パス部分フィルタσのパラメタ

<img width="500" height="562" alt="Image of GUI of Clip by Path (Area)" src="https://github.com/user-attachments/assets/58e45f51-7cb0-464e-85c2-605cfe565ab4" />
<img width="500" height="772" alt="Image of GUI of Clip by Path (Line)" src="https://github.com/user-attachments/assets/475f8dfb-55f2-44c2-b8d8-bb3527e3524d" />
<img width="500" height="528" alt="Image of GUI of Partial Filter by Path" src="https://github.com/user-attachments/assets/a79a205b-49b2-4a45-8560-7384d58e9821" />

####  強さ

*「パスマスクσ」と「パスマスク(ライン)σ」のみの項目です．*

マスクによる影響の強さを指定します．

% 単位で指定，最小値は 0, 最大値は 100, 初期値は 100.

####  反転

フィルタ効果の影響する範囲を反転します．

初期値は OFF.

> [!TIP]
> 「パスマスクσ」において，[「範囲」](#範囲--塗り範囲)を `内側反転` や `奇偶反転` にした場合の違いとは影響が異なり，[「追加幅」](#追加幅--塗り追加幅)を変化させたときに膨張する方向が変わってきます．

####  移動X, 移動Y, 拡大率, 回転

指定したパスを，各頂点を操作せず拡大・回転・平行移動することができます．

[「アンカー切り替え」](#アンカー切り替え)が ON の場合，「移動X」と「移動Y」をアンカーによるマウス操作でも動かせるようになります．

1.  「移動X」と「移動Y」はピクセル単位で指定，最小値は -4000, 最大値は 4000, 初期値は 0.
1.  「拡大率」は % 単位で指定，最小値は 0, 最大値は 5000, 初期値は 100.
1.  「回転」は時計回りの度数単位で指定，最小値は -720, 最大値は 720, 初期値は 0.

####  アンカー切り替え

プレビュー画面のアンカーを，[「点リスト」](#点リスト)の操作と，[「移動X」と「移動Y」](#移動x-移動y-拡大率-回転)の操作とで切り替えます．

- OFF の場合は「点リスト」のアンカーを表示・操作．
- ON の場合は「移動X」と「移動Y」のアンカーを表示・操作．

初期値は OFF.

- この項目は [`PI`](#pi) による操作ができません．


### パスに沿って配置σのパラメタ

<img width="500" height="458" alt="Image of GUI of Place Along Path" src="https://github.com/user-attachments/assets/386e1f7a-63ac-422d-8671-21eed9d1daa6" />

####  位置

オブジェクトを配置する位置を，パス全体の長さからの割合で % 単位で指定します．[「ループ」](#ループ)が ON の場合，0 % を下回った分はパスの終了点から，100 % を上回った分はパスの開始点からカウントされます．

最小値は -200, 最大値は 200, 初期値は 0.

####  回転

オブジェクトの回転角度を指定します．

時計回りの度数法で指定，最小値は -720, 最大値は 720, 初期値は 0.

####  パスに沿って回転

オブジェクトの角度をパスに沿って調整します．

初期値は ON.

####  個別位置ズレ

個別オブジェクトのときにのみ有効な設定です．個別オブジェクトそれぞれの配置間隔を，パス全体の長さからの割合で % 単位で指定します．

最小値は -200, 最大値は 200, 初期値は -5.

####  範囲外

[「位置」](#位置)や[「個別位置ズレ」](#個別位置ズレ)による計算で，開始点より前や終了点より後ろになった場合の処理を指定します．

1.  `非表示` :arrow_right: 開始点より前や終了点より後ろの場合は表示しません．
1.  `始点のみ表示` :arrow_right: 開始点より前の場合，開始点に表示します．終了点より後ろの場合は表示しません．
1.  `終点のみ表示` :arrow_right: 開始点より前の場合は表示しません．終了点より後ろの場合，終了点に表示します．
1.  `表示` :arrow_right: 開始点より前や終了点より後ろの場合，それぞれ開始点や終了点に表示します．

- [「ループ」](#ループ)が OFF のときのみ有効な設定です．

初期値は `非表示`.

####  パスの表示

設定したパスを点線で表示します．動画出力時にはやプレビュー時にはこの点線は表示されません．

初期値は OFF.

- この項目は [`PI`](#pi) による操作ができません．


### `PI`

パラメタインジェクション (parameter injection) です．初期値は空欄. テーブル型の中身として解釈され，各種パラメタの代替値として使用されます．また，任意のスクリプトコードを実行する記述領域にもなります．

- テキストボックスには冒頭末尾の波括弧 (`{}`) を省略して記述してください．
- 一部は別スクリプトからの利用を想定した項目になっています．利用する場合は `Path_S.lua` を `require` して，その API も併用してください．

####  パス図形σの `PI`

```lua
{
  num_points = num,    -- number 型で "頂点数" の項目を上書き，または nil.
  path_type = str,     -- string 型で "線タイプ" の項目を上書き，または nil.
  points = tab,        -- table 型で "点リスト" の項目を上書き，または nil.
  precision = num,     -- number 型で "曲線精度" の項目を上書き，または nil.
  antialias = num,     -- number 型で "ぼかし幅" の項目を上書き，または nil.
  color_line = num,    -- number 型で "ライン色" の項目を上書き，または nil.
  alpha_line = num,    -- number 型で "ライン透明度" の項目を上書き，または nil.
  line = num,          -- number 型で "ライン幅" の項目を上書き，または nil.
  loop = bool,         -- boolean 型で "ループ" を上書き，または nil. 0 を false, 0 以外を true として number 型も可能．
  start_pos = num,     -- number 型で "開始位置" の項目を上書き，または nil.
  end_pos = num,       -- number 型で "終了位置" の項目を上書き，または nil.
  end_shape = str,     -- string 型で "端の形状" の項目を上書き，または nil.
  dash_pat = tbl,      -- table 型で "破線パターン" の項目を上書き，または nil.
  dash_adj = bool,     -- boolean 型で "破線周期補正" を上書き，または nil. 0 を false, 0 以外を true として number 型も可能．
  dash_pos = num,      -- number 型で "破線位置" の項目を上書き，または nil.
  color_fill = num,    -- number 型で "塗り色" の項目を上書き，または nil.
  alpha_fill = num,    -- number 型で "塗り透明度" の項目を上書き，または nil.
  inflation = num,     -- number 型で "塗り追加幅" の項目を上書き，または nil.
  mode_fill = str,     -- string 型で "塗り範囲" の項目を上書き，または nil.
  rand_period = num,   -- number 型で "ランダム周期" の項目を上書き，または nil.
  rand_amplify = num,  -- number 型で "ランダム振幅" の項目を上書き，または nil.
  rand_fix_end = bool, -- boolean 型で "ランダム固定端" を上書き，または nil. 0 を false, 0 以外を true として number 型も可能．
  rand_seed = num,     -- number 型で "ランダムシード" の項目を上書き，または nil.
}
```

####  ラインσの `PI`

```lua
{
  X = num, Y = num,    -- number 型で "終点X", "終点Y" の項目を上書き，または nil.
  color = num,         -- number 型で "色" の項目を上書き，または nil.
  line = num,          -- number 型で "ライン幅" の項目を上書き，または nil.
  end_shape = str,     -- string 型で "端の形状" の項目を上書き，または nil.
  line_shape = str,    -- string 型で "形状" の項目を上書き，または nil.
  antialias = num,     -- number 型で "ぼかし幅" の項目を上書き，または nil.
  line_period = num,   -- number 型で "周期" の項目を上書き，または nil.
  line_phase = num,    -- number 型で "周期位置" の項目を上書き，または nil.
  line_amplify = num,  -- number 型で "振幅" の項目を上書き，または nil.
  dash_pat = tab,      -- table 型で "破線パターン" の項目を上書き，または nil.
  dash_pos = num,      -- number 型で "破線位置" の項目を上書き，または nil.
  rand_period = num,   -- number 型で "ランダム周期" の項目を上書き，または nil.
  rand_amplify = num,  -- number 型で "ランダム振幅" の項目を上書き，または nil.
  rand_fix_end = bool, -- boolean 型で "ランダム固定端" を上書き，または nil. 0 を false, 0 以外を true として number 型も可能．
  rand_seed = num,     -- number 型で "ランダムシード" の項目を上書き，または nil.
}
```

####  スパイラルσの `PI`

```lua
{
  slope = num,         -- number 型で "傾き" の項目を上書き，または nil.
  color = num,         -- number 型で "色" の項目を上書き，または nil.
  line = num,          -- number 型で "ライン幅" の項目を上書き，または nil.
  end_shape = str,     -- string 型で "端の形状" の項目を上書き，または nil.
  line_shape = str,    -- string 型で "形状" の項目を上書き，または nil.
  precision = num,     -- number 型で "曲線精度" の項目を上書き，または nil.
  antialias = num,     -- number 型で "ぼかし幅" の項目を上書き，または nil.
  start_radius = num,  -- number 型で "開始半径" の項目を上書き，または nil.
  end_radius = num,    -- number 型で "終了半径" の項目を上書き，または nil.
  rotate = num,        -- number 型で "回転" の項目を上書き，または nil.
  X = num, Y = num,    -- number 型で "ずれX", "ずれY" の項目を上書き，または nil.
  dash_pat = tab,      -- table 型で "破線パターン" の項目を上書き，または nil.
  dash_pos = num,      -- number 型で "破線位置" の項目を上書き，または nil.
  rand_period = num,   -- number 型で "ランダム周期" の項目を上書き，または nil.
  rand_amplify = num,  -- number 型で "ランダム振幅" の項目を上書き，または nil.
  rand_fix_end = bool, -- boolean 型で "ランダム固定端" を上書き，または nil. 0 を false, 0 以外を true として number 型も可能．
  rand_seed = num,     -- number 型で "ランダムシード" の項目を上書き，または nil.
}
```

####  アローσの `PI`

```lua
{
  color = num,         -- number 型で "色" の項目を上書き，または nil.
  line = num,          -- number 型で "ライン幅" の項目を上書き，または nil.
  head_type = str,     -- string 型で "矢じり配置" の項目を上書き，または nil.
  head_fig = str,      -- string 型で "矢じり図形" の項目を上書き，または nil.
  head_size = num,     -- number 型で "矢じりサイズ" の項目を上書き，または nil.
  head_width = num,    -- number 型で "矢じり幅" の項目を上書き，または nil.
  head_center = num,   -- number 型で "矢じり中心" の項目を上書き，または nil.
  head_rot = num,      -- number 型で "矢じり角度" の項目を上書き，または nil.
  head_pos = num,      -- number 型で "矢じり位置" の項目を上書き，または nil.
  num_points = num,    -- number 型で "頂点数" の項目を上書き，または nil.
  path_type = str,     -- string 型で "線タイプ" の項目を上書き，または nil.
  points = tab,        -- table 型で "点リスト" の項目を上書き，または nil.
  precision = num,     -- number 型で "曲線精度" の項目を上書き，または nil.
  antialias = num,     -- number 型で "ぼかし幅" の項目を上書き，または nil.
  start_pos = num,     -- number 型で "開始位置" の項目を上書き，または nil.
  end_pos = num,       -- number 型で "終了位置" の項目を上書き，または nil.
  end_shape = str,     -- string 型で "端の形状" の項目を上書き，または nil.
  dash_pat = tab,      -- table 型で "破線パターン" の項目を上書き，または nil.
  dash_pos = num,      -- number 型で "破線位置" の項目を上書き，または nil.
  rand_period = num,   -- number 型で "ランダム周期" の項目を上書き，または nil.
  rand_amplify = num,  -- number 型で "ランダム振幅" の項目を上書き，または nil.
  rand_fix_end = bool, -- boolean 型で "ランダム固定端" を上書き，または nil. 0 を false, 0 以外を true として number 型も可能．
  rand_seed = num,     -- number 型で "ランダムシード" の項目を上書き，または nil.
}
```

####  パスマスクσの `PI`

```lua
{
  intensity = num,  -- number 型で "強さ" の項目を上書き，または nil.
  num_points = num, -- number 型で "頂点数" の項目を上書き，または nil.
  path_type = str,  -- string 型で "線タイプ" の項目を上書き，または nil.
  points = tab,     -- table 型で "点リスト" の項目を上書き，または nil.
  precision = num,  -- number 型で "曲線精度" の項目を上書き，または nil.
  antialias = num,  -- number 型で "ぼかし幅" の項目を上書き，または nil.
  inflation = num,  -- number 型で "追加幅" の項目を上書き，または nil.
  mode_fill = num,  -- string 型で "範囲" の項目を上書き，または nil.
  invert = bool,    -- boolean 型で "反転" を上書き，または nil. 0 を false, 0 以外を true として number 型も可能．
  X = num, Y = num, -- number 型で "移動X", "移動Y" の項目を上書き，または nil.
  zoom = num,       -- number 型で "拡大率" の項目を上書き，または nil.
  rotate = num,     -- number 型で "回転" の項目を上書き，または nil.
  pt_buff = str,    -- string 型で, パスの頂点情報を保持している画像バッファ名を指定，または nil. 詳細後述．
}
```

フィールド `.pt_buff` は `"tempbuffer"` か `"cache:****"` の形式の文字列で，`Path_S.lua` の `.send()` 関数によって頂点情報が保持されている画像バッファ名を指定します．この場合，次に注意してください:
1.  「頂点数」または `.num_points` にはこのバッファに保持された点の個数を指定すること．
1.  次のパラメタやフィールドは無視されます:
    1.  「線タイプ」と `.path_type`.
    1.  「点リスト」と `.points`.
    1.  「曲線精度」と `.precision`.
    1.  「移動X」と `.X`, 「移動Y」と `.Y`.
    1.  「拡大率」と `.zoom`.
    1.  「回転」と `.rotate`.
1.  指定された頂点は折れ線と解釈して描画されます．


####  パスマスク(ライン)σの `PI`

```lua
{
  line = num,       -- number 型で "ライン幅" の項目を上書き，または nil.
  intensity = num,  -- number 型で "強さ" の項目を上書き，または nil.
  num_points = num, -- number 型で "頂点数" の項目を上書き，または nil.
  path_type = str,  -- string 型で "線タイプ" の項目を上書き，または nil.
  points = tab,     -- table 型で "点リスト" の項目を上書き，または nil.
  precision = num,  -- number 型で "曲線精度" の項目を上書き，または nil.
  antialias = num,  -- number 型で "ぼかし幅" の項目を上書き，または nil.
  loop = bool,      -- boolean 型で "ループ" を上書き，または nil. 0 を false, 0 以外を true として number 型も可能．
  start_pos = num,  -- number 型で "開始位置" の項目を上書き，または nil.
  end_pos = num,    -- number 型で "終了位置" の項目を上書き，または nil.
  end_shape = str,  -- string 型で "端の形状" の項目を上書き，または nil.
  dash_pat = tab,   -- table 型で "破線パターン" の項目を上書き，または nil.
  dash_adj = bool,  -- boolean 型で "破線周期補正" を上書き，または nil. 0 を false, 0 以外を true として number 型も可能．
  dash_pos = num,   -- number 型で "破線位置" の項目を上書き，または nil.
  invert = bool,    -- boolean 型で "反転" を上書き，または nil. 0 を false, 0 以外を true として number 型も可能．
  X = num, Y = num, -- number 型で "移動X", "移動Y" の項目を上書き，または nil.
  zoom = num,       -- number 型で "拡大率" の項目を上書き，または nil.
  rotate = num,     -- number 型で "回転" の項目を上書き，または nil.
  pt_buff = str,    -- string 型で, パスの頂点情報を保持している画像バッファ名を指定，または nil. 詳細後述．
  len_buff = num,   -- number 型で, パス全体のピクセル長を指定，または nil. 詳細後述．
  endpt_buff = tab, -- table 型で, パスの両端の座標と方向を記述，または nil. 詳細後述．
}
```

フィールド `.pt_buff` は `"tempbuffer"` か `"cache:****"` の形式の文字列で，`Path_S.lua` の `.send()` 関数によって頂点情報が保持されている画像バッファ名を指定します．この場合，次に注意してください:
1.  「頂点数」または `.num_points` にはこのバッファに保持された点の個数を指定すること．
1.  `.len_buff` にはパス全体のピクセル長を指定すること．
1.  「端の形状」または `.end_shape` が `四角` の場合，`.endpt_buff` にはパスの両端の座標と方向を記述した配列を指定すること．形式は次の通り:

    ```lua
    {
      x1, y1,   -- 始点の座標．
      dx1, dy1, -- 始点の方向ベクトル．
      x2, y2,   -- 終点の座標．
      dx2, dy2, -- 終点の方向ベクトル．
    }
    ```
    - 方向ベクトルは始点から終点へ向かう方向で指定．正規化されている必要はありません．
    - 「端の形状」や `.end_shape` が `円` の場合は `.endpt_buff` は無視されます．

1.  次のパラメタやフィールドは無視されます:
    1.  「線タイプ」と `.path_type`.
    1.  「点リスト」と `.points`.
    1.  「曲線精度」と `.precision`.
    1.  「移動X」と `.X`, 「移動Y」と `.Y`.
    1.  「拡大率」と `.zoom`.
    1.  「回転」と `.rotate`.
1.  指定された頂点は折れ線と解釈して描画されます．

`.pt_buff` が `nil` の場合は，`.len_buff` と `.endpt_buff` は無視されます．


####  パス部分フィルタσの `PI`

```lua
{
  num_points = num, -- number 型で "頂点数" の項目を上書き，または nil.
  path_type = str,  -- string 型で "線タイプ" の項目を上書き，または nil.
  points = tab,     -- table 型で "点リスト" の項目を上書き，または nil.
  precision = num,  -- number 型で "曲線精度" の項目を上書き，または nil.
  antialias = num,  -- number 型で "ぼかし幅" の項目を上書き，または nil.
  inflation = num,  -- number 型で "追加幅" の項目を上書き，または nil.
  mode_fill = num,  -- string 型で "範囲" の項目を上書き，または nil.
  invert = bool,    -- boolean 型で "反転" を上書き，または nil. 0 を false, 0 以外を true として number 型も可能．
  X = num, Y = num, -- number 型で "移動X", "移動Y" の項目を上書き，または nil.
  zoom = num,       -- number 型で "拡大率" の項目を上書き，または nil.
  rotate = num,     -- number 型で "回転" の項目を上書き，または nil.
}
```

####  パスに沿って配置σの `PI`

```lua
{
  position = num,     -- number 型で "位置" の項目を上書き，または nil.
  rotate = num,       -- number 型で "回転" の項目を上書き，または nil.
  rot_tangent = bool, -- boolean 型で "パスに沿って回転" を上書き，または nil. 0 を false, 0 以外を true として number 型も可能．
  ofs_indiv = num,    -- number 型で "個別位置ズレ" の項目を上書き，または nil.
  out_of_range = str, -- string 型で "範囲外" の項目を上書き，または nil.
  num_points = num,   -- number 型で "頂点数" の項目を上書き，または nil.
  path_type = str,    -- string 型で "線タイプ" の項目を上書き，または nil.
  points = tab,       -- table 型で "点リスト" の項目を上書き，または nil.
  precision = num,    -- number 型で "曲線精度" の項目を上書き，または nil.
  loop = bool,        -- boolean 型で "ループ" を上書き，または nil. 0 を false, 0 以外を true として number 型も可能．
}
```


##  既知の問題

1.  [「パス部分フィルタσ」](#パス部分フィルタσ)では，一部のフィルタ効果は後続に置いても「部分的に適用」されるような挙動にはなりません．

    「ランダム移動」や「球体(カメラ制御)」など，フレームバッファに直接描画したり，カメラ制御を前提としたり，配置を変えるフィルタ効果などが当てはまることが多いです．

1.  [「パス部分フィルタσ」](#パス部分フィルタσ)は，1つのオブジェクトに対して複数設定できません (つまり「入れ子」のような構造は指定不可能).

1.  AviUtl2 では「個別オブジェクト」が有効の時にはパスやアンカーが表示されないため，[「パスに沿って配置σ」](#パスに沿って配置σ)などを「個別オブジェクト」に対して適用した場合はパスが表示されません．この場合，一時的に「個別オブジェクト」を解除してからパスを調整，そのあとに「個別オブジェクト」を再度有効にしてください．

##  改版履歴

- **v1.00 (for beta20)** (2025-11-21)

  - 初版．


## ライセンス

このプログラムの利用・改変・再頒布等に関しては MIT ライセンスに従うものとします．

---

The MIT License (MIT)

Copyright (C) 2025 sigma-axis

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

https://mit-license.org/


#  連絡・バグ報告

- GitHub: https://github.com/sigma-axis
- Twitter: https://x.com/sigma_axis
- nicovideo: https://www.nicovideo.jp/user/51492481
- Misskey.io: https://misskey.io/@sigma_axis
- Bluesky: https://bsky.app/profile/sigma-axis.bsky.social
