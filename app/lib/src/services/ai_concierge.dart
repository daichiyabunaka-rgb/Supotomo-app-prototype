import '../models.dart';

/// AI接客のデモ応答ロジック（プロトタイプ用のモック）。
/// 本開発では LLM API に置き換える。このロジックは店舗業態と
/// ユーザーの興味カテゴリからおすすめを案内する最低限のルールベース。
class AiConcierge {
  /// 最初の挨拶（店舗の口調 + ユーザーの興味を踏まえる）
  String greeting(AppUser me, BusinessUser store) {
    final interest = me.interestIds.isNotEmpty ? me.interestIds.first : null;
    final label = interest == null ? null : _categoryLabel(interest);
    final base = '${_opener(store)}'
        '${me.nickname}さん、${store.nickname}（${store.storeType}）のAI接客です。';
    if (label == null) {
      return '$base スポーツのことなら何でも聞いてください。';
    }
    return '$base $labelがお好みなんですね。'
        'うちの${_recommend(store)}がおすすめです。';
  }

  /// 店舗タイプごとの口調（本開発では LLM に店舗キャラ設定を渡して生成する）
  String _opener(BusinessUser store) {
    switch (store.storeType) {
      case 'スポーツジム':
        return 'いらっしゃい！マシンもスタジオも使い放題です。';
      case '体育館・スポーツ施設運営':
        return 'いらっしゃいませ。コートの空き状況もご案内できます。';
      case 'スポーツ教室・スクール':
        return 'いらっしゃい。体験レッスンも受け付けています。';
      case 'スポーツ用品店':
        return 'こんにちは。用品選びもお手伝いします。';
      case 'ゴルフ練習場':
        return 'ようこそ。打ち放題コースのご案内もできます。';
      case 'ランニングシューズ店・スポーツ用品店':
        return 'ようこそ。シューズフィッティングもやっています。';
      default:
        return 'いらっしゃいませ。';
    }
  }

  /// ユーザー発話への応答
  String reply(String input, AppUser me, BusinessUser store) {
    final text = input.replaceAll(RegExp(r'\s'), '');
    if (text.contains('予約') || text.contains('来店') || text.contains('利用')) {
      return 'ありがとうございます。土日は混み合うため、'
          '平日の午前中でしたらゆっくりご案内できます。'
          'ご希望の時間をメモしておきますね。'
          '（デモのため実際の予約機能は本開発で提供します）';
    }
    if (text.contains('おすすめ') || text.contains('オススメ')) {
      return '今回は${_recommend(store)}がおすすめです。'
          '練習やイベントの予定があれば教えてください。';
    }
    if (text.contains('練習') || text.contains('ジム') ||
        text.contains('試合') || text.contains('コーチ')) {
      return '初めての方も歓迎しています。'
          'レベルに合わせてメニューを一緒に考えます。';
    }
    if (text.contains('料金') || text.contains('いくら') ||
        text.contains('価格')) {
      return 'ご利用内容によって変わりますが、まずは一度お試しいただけます。'
          '詳しいプランは店舗ページをご確認ください（デモの固定値です）。';
    }
    if (text.contains('何時') || text.contains('営業時間')) {
      return '本日は10:00〜18:00で営業しております。'
          '混雑しやすいのは土曜午前です。（デモの固定値です）';
    }
    if (text.contains('駐車場') || text.contains('アクセス')) {
      return '近隣にコインパーキングがあります。'
          '大きな荷物がある場合は事前にご相談ください。';
    }
    return '承知しました。「おすすめ」「料金」「営業時間」「予約」「練習」など、'
        '気になることを聞いていただければ答えます。';
  }

  String _recommend(BusinessUser store) {
    switch (store.storeType) {
      case 'スポーツジム':
        return '平日の夕方混雑前のマシン枠';
      case '体育館・スポーツ施設運営':
        return 'コートの空いている平日夜';
      case 'スポーツ教室・スクール':
        return '初心者向けの体験レッスン';
      case 'スポーツ用品店':
        return '中古シューズ・ラケットの整理セール品';
      case 'ゴルフ練習場':
        return '週末の打ち放題とレッスンセット';
      case 'ランニングシューズ店・スポーツ用品店':
        return 'ランニングシューズのフィッティング';
      default:
        return 'おすすめサービス';
    }
  }

  String _categoryLabel(String id) {
    const labels = {
      'running': 'ランニング・ジョギング',
      'walking': 'ウォーキング',
      'soccer': 'サッカー・フットサル',
      'baseball': '野球・ソフトボール',
      'tennis': 'テニス',
      'basketball': 'バスケットボール',
      'volleyball': 'バレーボール',
      'tabletennis': '卓球・バドミントン',
      'golf': 'ゴルフ',
      'swimming': '水泳',
      'gym': '筋トレ・ジム',
      'cycling': 'サイクリング',
    };
    return labels[id] ?? 'スポーツのこと';
  }
}

/// グローバルインスタンス（本開発では DI / LLM API クライアントに置き換える）
final AiConcierge aiConcierge = AiConcierge();
