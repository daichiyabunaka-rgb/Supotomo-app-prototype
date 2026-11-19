# スポとも！（Supotomo）

**スポーツ好き同士が、趣味・中身ベースでつながる趣味特化型マッチングアプリのプロトタイプです。** 近くの同じ種目の人（スポとも）を探して一緒に練習・大会・観戦に誘い合えます。ともつく！シリーズの第10弾（スポーツ Edition・種目ソート付き）で、第8弾: [音とも！Ototomo](https://github.com/daichiyabunaka-rgb/Ototomo-app-prototype)、第9弾: [湯とも！Yutomo](https://github.com/daichiyabunaka-rgb/Yutomo-app-prototype) の設計を踏襲しています。

ビジネスモデルは、**一般ユーザー（無料）とビジネスユーザー（スポーツジム・スポーツ施設・用品店・スクールなどの事業者）** の2層構造です。

## コンセプト・設計原則

| 原則 | 内容 |
|---|---|
| 本人の顔画像禁止 | アイコンは**競技・練習・大会風景に関連する画像のみ**許可。本人の素顔がメインの画像はアップロード不可 |
| マナー遵守 | 施設・コートの利用ルールを常に確認する設計。迷惑行為の募集は禁止文言で排除 |
| 恋愛目的禁止 | 出会い系としての法律が適用されないよう、利用規約で明示的に禁止 |
| 施設・競技場のルール | 近況報告は施設・競技場のルールを守り、他人が写る画像は許諾を得たもののみ投稿可 |
| 時限性 | 募集は期限付き（1〜3時間）。期限が来たら自動で消える |
| 距離は粗表示 | 位置は「〜1km / 1〜3km」のようなバンド表示のみ。正確な座標は非公開 |

**注意: モックデータには位置情報が含まれません。** モックの一般ユーザー・店舗は現在地（GPSまたは初期設定の場所）からの相対距離で配置されます。モックユーザーの配置先は端末内データのみに保存され、Supabase には送信されません。Supabase 接続時は Supabase 側のユーザーのデータのみ表示され、モックユーザーは表示されません。

## 実装機能（プロトタイプ）

- メール会員登録 / ログイン / ログアウト（端末内アカウント・セッションの永続化）
- GPS位置情報取得 →（距離バンド付きの）近くのスポとも / 店舗 / コミュニティ・イベントを一覧
- **種目ソート（本アプリの特殊差分）**: 「近く」の募集一覧と「探す」のコミュニティ一覧で、種目（興味カテゴリ）チップによる絞り込みができる
- 募集（一緒に練習・ゲームをしよう / 大会・イベント参戦 / 交流・オフ会。1〜3時間の期限付きで「今から」感を出す）
- 1:1のDM
- コミュニティ・イベント（誰でも作成・参加でき、参加するとチャットが始まる）
- **近くの施設（特別機能）**: 現在地周辺の OpenStreetMap（Overpass API）から、スポーツセンター・体育館（leisure=sports_centre）・ジム・フィットネス（leisure=fitness_centre）・競技場・スタジアム（leisure=stadium）・グラウンド・コート（leisure=pitch）・陸上トラック（leisure=track）を一覧表示。Googleマップで開く・その場で募集がワンタップで可能。民間の飲食店・公園は対象外
- **近況報告（特別機能、旧ゆずりあい・交換から変更）**: スポーツの近況を近隣で共有するボード。種別は「試合」（試合・練習の報告）「つぶやき」（近況・ひとこと）「イベント」（大会・イベント参戦の報告）の3種。投稿写真・掲載者へのDM・完了機能付き
- 興味カテゴリ（ランニング・ジョギング / ウォーキング / サッカー・フットサル / 野球・ソフトボール / テニス / バスケットボール / バレーボール / 卓球・バドミントン / ゴルフ / 水泳 / 筋トレ・ジム / サイクリング）はDBを通じて全ユーザーに共有される
- アイコン画像の投稿（Supabase Storage の公開バケットに自動リサイズ後アップロード。端末内フォールバック付き）
- **ともつく！シリーズとのアカウント共有**（他のともつく！アプリと同一の Supabase auth を共用。プロフィール・募集・DMは app_id でアプリごとに分離）
- **ともつく！連携**（アプリ横断表示 cross_app_visible・アプリ横断DM）

※ベータ版のため、メール登録確認機能・AI接客機能・ビジネスユーザーのAIチャットはロック中です。

## 構成

```
docs/
  要件定義書_スポとも_v1.md          機能要件・非機能要件・KPI・データモデル
  supabase_multiapp_migration.sql      共有DB化・app_id分離マイグレーション（tomotsuku-memo 0002相当）
  supabase_multiapp_v2_cross_app.sql   ともつく！連携（cross_app_visible。0003相当）
  supabase_supotomo_sports_goods.sql   旧ゆずりあい・交換テーブル・投稿写真バケットの作成（スポとも！用・0011相当。※0016でsports_reportsへ変更）
app/                            Flutter アプリ（Android / iOS / Web 対応）
  lib/src/screens/             画面（near_page に 募集/人/店舗/施設 の4セクション）
  lib/src/services/            認証・位置情報・Supabase Data Access（app_id フィルタ・RLSを前提）
  lib/src/util/cat_spots.dart   近くの施設取得（Overpass API・ミラーフォールバック・キャッシュ・GoogleマップURL生成）
  lib/src/mock/                 モックユーザー・シード募集（GPS現在地からの相対距離で配置）
tools/make_icon.py              ランチャーアイコン生成スクリプト（Python + Pillow。フラットデザインのサッカーボール）
```

## 起動手順

```powershell
cd app
flutter pub get
flutter run -d chrome          # ブラウザ
flutter run -d <デバイスID>     # Android 端末（flutter devices で確認）
flutter build apk --release     # APK ビルド
```

接続DBは「ともつく！」シリーズ共通の Supabase プロジェクトです（接続情報と鍵の扱いは tomotsuku-memo リポジトリ参照）。

```powershell
flutter build apk --release --dart-define=SUPABASE_URL=https://hlcsuogoghrgqabkaqxm.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=<tomotsuku-memo参照>
```

dart-define を付けない場合はローカルモック（端末内データのみ）で起動します。

静的解析: `flutter analyze` / 自動テスト: `flutter test`

## Supabase 接続の前提

1. **共通DB**: 飯とも！・犬とも！・釣りとも！・ニーアキャット・コスとも！・走りとも！・キャンとも！・音とも！・湯とも！と同じ Supabase プロジェクトを共有します（アカウント〈auth.users〉共通、その他のデータは app_id で分離）。
2. **事前に適用が必要なマイグレーション**: `docs/supabase_multiapp_migration.sql` と `docs/supabase_multiapp_v2_cross_app.sql`（tomotsuku-memo の 0002 / 0003 と同一内容）。
3. **スポとも！用**: `docs/supabase_supotomo_sports_goods.sql` を Supabase Dashboard の SQL Editor で適用してください（sports_goods_exchanges テーブルと sports-goods-photos バケット、services マスタへの 'supotomo' 登録、delete_my_account の更新）。tomotsuku-memo の 0011 マイグレーションと同一内容です。
4. **アイコン投稿バケット**: `icons` バケットはシリーズ共通です（ユーザーごとの `UUID/supotomo/` 名前空間に配置されるため使い回せます）。
5. **施設検索**: OpenStreetMap（Overpass API）を利用。APIキー不要・User-Agent必須。スポーツセンター・ジム・競技場・グラウンド・トラックのみ検索し、民間の飲食店・公園は対象外。施設の利用マナー・ルールの確認を常に案内します。
6. **画像モデレーション**: アイコンの顔画像検証等は本リリース版で実装予定（他アプリの Human/Animal 判定相当）。

## 運用

- スキーマ変更は必ず [tomotsuku-memo](https://github.com/daichiyabunaka-rgb/tomotsuku-memo)（Private）の master を先に変更し、そこから SQL Editor へ適用する運用ルールに従う
- クライアントには publishable key のみを埋め込む（`--dart-define` 経由）。secret key は絶対にコミットしない
