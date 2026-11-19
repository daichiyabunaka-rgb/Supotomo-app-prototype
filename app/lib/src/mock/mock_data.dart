import 'dart:math' as math;

import '../models.dart';

/// モックユーザーは「anchor（中心点）からの相対距離」で配置する。
/// anchor には実 GPS で取得した現在地が入り、どこにいても近くのスポとも候補が並ぶ。
class _MockSpec {
  final String id;
  final String nickname;
  final String decade;
  final String gender;
  final String iconCategoryId;
  final List<String> interestIds;
  final String bio;
  final double northKm; // anchor からの北方向距離
  final double eastKm; // anchor からの東方向距離

  const _MockSpec(this.id, this.nickname, this.decade, this.gender,
      this.iconCategoryId, this.interestIds, this.bio, this.northKm,
      this.eastKm);
}

const List<_MockSpec> _specs = [
  _MockSpec(
    'u-run-ken',
    'ランニングのけん',
    '30代',
    'male',
    'running',
    ['running', 'gym', 'cycling'],
    '朝5kmから始めて仕事前に走っています。フルマラソン完走が目標です。',
    0.6,
    0.2,
  ),
  _MockSpec(
    'u-soccer-akira',
    'サッカーのあきら',
    '40代',
    'male',
    'soccer',
    ['soccer', 'volleyball', 'gym'],
    'フットサル週2。参加型のゲームが好きです。ボランチ気味です。',
    -0.3,
    -0.1,
  ),
  _MockSpec(
    'u-tennis-nana',
    'テニスのなな',
    '20代',
    'female',
    'tennis',
    ['tennis', 'tabletennis', 'walking'],
    'ソフトテニスから硬式へ転向しました。ダブルスの仲間を探しています。',
    0.15,
    -0.4,
  ),
  _MockSpec(
    'u-basket-sora',
    'バスケのそら',
    '20代',
    'undisclosed',
    'basketball',
    ['basketball', 'volleyball', 'gym'],
    '3x3JPのエキシビションに出たことがあります。3on3の相手を探しています。',
    -0.7,
    0.5,
  ),
  _MockSpec(
    'u-golf-miu',
    'ゴルフのみう',
    '20代',
    'female',
    'golf',
    ['golf', 'walking', 'cycling'],
    'ラウンドデビュー3年目。100切りを目指して練習場に通っています。',
    1.2,
    -0.9,
  ),
  _MockSpec(
    'u-swim-kei',
    '水泳のけい',
    '30代',
    'undisclosed',
    'swimming',
    ['swimming', 'gym', 'running'],
    '朝練で1.5km泳いでいます。マスターズ大会にも参戦しています。',
    -1.1,
    1.0,
  ),
  _MockSpec(
    'u-gym-hina',
    '筋トレのひな',
    '30代',
    'female',
    'gym',
    ['gym', 'running', 'swimming'],
    '週4ジム。ベンチプレイの記録更新が楽しみです。一緒に追い込みませんか。',
    0.9,
    0.35,
  ),
  _MockSpec(
    'u-baseball-kyo',
    '野球のきょう',
    '40代',
    'male',
    'baseball',
    ['baseball', 'golf', 'tabletennis'],
    '草野球でショートを守っています。バッティング練習相手を募集しています。',
    0.45,
    -1.3,
  ),
];

class _BusinessSpec {
  final String id;
  final String nickname;
  final String iconCategoryId;
  final String storeType;
  final String bio;
  final double northKm;
  final double eastKm;

  const _BusinessSpec(this.id, this.nickname, this.iconCategoryId,
      this.storeType, this.bio, this.northKm, this.eastKm);
}

const List<_BusinessSpec> _businessSpecs = [
  _BusinessSpec(
    'b-fit-arena',
    'フィットネスジム アレナ',
    'gym',
    'スポーツジム',
    '24時間営業のジム。スタジオレッスンも毎日開講しています。見学無料。',
    0.8,
    0.9,
  ),
  _BusinessSpec(
    'b-center-chuo',
    'スポーツセンター 中央',
    'volleyball',
    '体育館・スポーツ施設運営',
    '球技場・プール・トレーニング室を備えた区民施設。コートの予約もできます。',
    -0.5,
    1.1,
  ),
  _BusinessSpec(
    'b-golf-greenhill',
    'ゴルフ練習場 グリーンヒル',
    'golf',
    'ゴルフ練習場',
    '打ち放題コースあり。グループレッスンも随時開講しています。',
    1.5,
    -0.6,
  ),
  _BusinessSpec(
    'b-shop-frespo',
    'スポーツ用品店 フレスポ',
    'tennis',
    'スポーツ用品店',
    '中古ラケット・シューズの買取りと販売。無料査定とグリップ交換もやっています。',
    -1.4,
    -0.8,
  ),
];

const double _kmPerDegLat = 111.32;

AppUser _specToUser(_MockSpec s, double anchorLat, double anchorLng) {
  final cos =
      math.cos(anchorLat * math.pi / 180.0).abs().clamp(0.01, 1.0);
  return AppUser(
    id: s.id,
    nickname: s.nickname,
    decade: s.decade,
    gender: s.gender,
    iconCategoryId: s.iconCategoryId,
    interestIds: s.interestIds,
    bio: s.bio,
    lat: anchorLat + s.northKm / _kmPerDegLat,
    lng: anchorLng + s.eastKm / (_kmPerDegLat * cos),
  );
}

BusinessUser _specToBusiness(
    _BusinessSpec s, double anchorLat, double anchorLng) {
  final cos =
      math.cos(anchorLat * math.pi / 180.0).abs().clamp(0.01, 1.0);
  return BusinessUser(
    id: s.id,
    nickname: s.nickname,
    decade: '経営者',
    gender: 'undisclosed',
    iconCategoryId: s.iconCategoryId,
    interestIds: const [],
    bio: s.bio,
    lat: anchorLat + s.northKm / _kmPerDegLat,
    lng: anchorLng + s.eastKm / (_kmPerDegLat * cos),
    storeType: s.storeType,
  );
}

/// 現在地を中心にモックユーザー（一般 + ビジネス）を配置する。
List<AppUser> buildMockUsers(double anchorLat, double anchorLng) {
  return [
    for (final s in _specs) _specToUser(s, anchorLat, anchorLng),
    for (final s in _businessSpecs) _specToBusiness(s, anchorLat, anchorLng),
  ];
}

/// シード募集（起動時刻からの残り時間で作るので、いつ開いても「今から」感が出る）。
/// host は generalUsers（モック一般ユーザー）から id で引く。
List<Recruitment> seedRecruitments(DateTime now, List<AppUser> generalUsers) {
  Recruitment make({
    required String hostId,
    required String genreId,
    required String title,
    required String body,
    required String meetup,
    required int capacity,
    required int minutesLeft,
  }) {
    return Recruitment(
      id: 'r-$hostId',
      hostId: hostId,
      genreId: genreId,
      title: title,
      body: body,
      meetup: meetup,
      capacity: capacity,
      createdAt: now.subtract(const Duration(minutes: 15)),
      expiresAt: now.add(Duration(minutes: minutesLeft)),
      memberIds: [hostId],
    );
  }

  return [
    make(
      hostId: 'u-soccer-akira',
      genreId: 'play',
      title: '今夜、フットサルをしませんか',
      body: 'スポーツセンターのコートを1面借りました。初心者も歓迎です。',
      meetup: 'スポーツセンター 中央 正面入口',
      capacity: 6,
      minutesLeft: 105,
    ),
    make(
      hostId: 'u-run-ken',
      genreId: 'play',
      title: '今から川沿いを一緒に走りませんか',
      body: '5分/kmでのんびり一周します。ゴール後のストレッチもどうぞ。',
      meetup: '区民体育館前の広場',
      capacity: 4,
      minutesLeft: 70,
    ),
    make(
      hostId: 'u-basket-sora',
      genreId: 'event',
      title: '週末の試合、観戦しませんか',
      body: 'スポーツバーでプロの試合を観戦します。戦術談義も大歓迎。',
      meetup: 'スポーツバー ハードワーク 前',
      capacity: 4,
      minutesLeft: 160,
    ),
    make(
      hostId: 'u-tennis-nana',
      genreId: 'event',
      title: 'テニスの合同練習会',
      body: '球出しからゲーム形式まで。ラケットの貸し借りも相談できます。',
      meetup: '区営テニスコート 第2面',
      capacity: 4,
      minutesLeft: 95,
    ),
    make(
      hostId: 'u-golf-miu',
      genreId: 'talk',
      title: 'スコア分析の勉強会をやります',
      body: 'ラウンド動画を見せ合って改善点を話し合う会です。',
      meetup: 'カフェ（スポーツ用品店 フレスポ となり）',
      capacity: 4,
      minutesLeft: 130,
    ),
    make(
      hostId: 'u-baseball-kyo',
      genreId: 'talk',
      title: '草野球チームの見学に来ませんか',
      body: '練習見学から参加できます。守備位置の相談もどうぞ。',
      meetup: '区民グランド ベンチ前',
      capacity: 3,
      minutesLeft: 45,
    ),
  ];
}

/// 近況報告のシード。anchor（現在地）からの相対距離で配置する。
/// id が 'cx-seed-' 始まりのものは GPS 更新のたびに再配置される
/// （AppState.applyGps を参照）。
class _ExchangeSeedSpec {
  final String id;
  final String posterId;
  final String kind;
  final String itemDescription;
  final String areaName;
  final String detail;
  final double northKm;
  final double eastKm;
  final Duration age;
  const _ExchangeSeedSpec(this.id, this.posterId, this.kind,
      this.itemDescription, this.areaName, this.detail, this.northKm,
      this.eastKm, this.age);
}

const List<_ExchangeSeedSpec> _exchangeSeedSpecs = [
  _ExchangeSeedSpec(
    'cx-seed-1',
    'u-baseball-kyo',
    'match',
    '練習試合で2得点を決めました',
    'スポーツセンター 中央 周辺',
    '接戦で勝てました。'
        '次のメンバーも募集しています。',
    0.3,
    -0.6,
    Duration(hours: 2),
  ),
  _ExchangeSeedSpec(
    'cx-seed-2',
    'u-tennis-nana',
    'post',
    '今週末はテニスの練習会に参加します',
    '駅前広場 周辺',
    '週末の天気も良さそうなので練習に集中できそうです。'
        '同じレベルの方とラリーをしたいです。',
    -0.2,
    0.8,
    Duration(hours: 5),
  ),
  _ExchangeSeedSpec(
    'cx-seed-3',
    'u-golf-miu',
    'event',
    '初心者ゴルフコンペに参加してきました',
    '市役所裏の公園 周辺',
    '初めてのコースデビューで緊張しましたが'
        '楽しく回れました。次回も参加予定です。',
    -0.9,
    -0.3,
    Duration(hours: 26),
  ),
];

List<SportsReport> buildSeedSportsReports(
    DateTime now, double anchorLat, double anchorLng) {
  final cos = (anchorLat * math.pi / 180.0).abs().clamp(0.01, 1.0);
  return [
    for (final s in _exchangeSeedSpecs)
      SportsReport(
        id: s.id,
        posterId: s.posterId,
        kind: s.kind,
        itemDescription: s.itemDescription,
        areaName: s.areaName,
        detail: s.detail,
        lat: anchorLat + s.northKm / _kmPerDegLat,
        lng: anchorLng + s.eastKm / (_kmPerDegLat * cos),
        createdAt: now.subtract(s.age),
      ),
  ];
}

/// モックの返信候補（デモの自動応答に使う。本開発では Supabase Realtime に置換）
const List<String> mockReplies = [
  'よろしくお願いします！',
  '次の練習、楽しみですね。',
  '先に着いてコートの受付を済ませておきますね。',
  'ウォームアップから始めましょうか。',
];

/// モックの応募メッセージ
const List<String> mockApplyMessages = [
  '参加したいです！スポーツ仲間を探していました。',
  '同じ競技をやっているので嬉しいです。',
  'この近くの大会によく参戦しています。',
];
