-- ============================================================
-- 0011_supotomo: スポとも！（第10弾・スポーツ Edition）
-- 対象: 共有Supabaseプロジェクト（追加のみ・非破壊・トランザクション）
--
-- 内容:
--   1. services マスタへ 'supotomo' を追加
--   2. sports_goods_exchanges テーブル（スポーツ用品のゆずりあい・交換ボード）
--      - kind: give（ゆずる）/ wanted（探す）/ trade（交換）
--      - 金銭取引は禁止（無償の譲り合い・物々交換のみ。受け渡しは
--        スポーツ施設の入口前・駅前広場など人目のある場所を前提とした設計）
--      - poster_id の FK はマルチテナント化後のスキーマに合わせ
--        auth.users を参照する（profiles は (id, app_id) 複合PKのため）
--   3. 投稿写真バケット sports-goods-photos（公開・ユーザーごとUUID名前空間）
--      - アップロードパスは <uid>/supotomo/item_photo_*.jpg
--      - （アプリアイコン等はシリーズ共通の icons バケットを使う）
--   4. delete_my_account() へ sports_goods_exchanges 削除を追加
--
-- 前提: 0002_multiapp 〜 0010_yutomo が適用済みであること。
--       番号順に適用する運用（提案006）に従うこと。
-- ============================================================

begin;

-- ------------------------------------------------------------
-- 1. services マスタへスポとも！を追加
-- ------------------------------------------------------------
insert into public.services (id, label) values
  ('supotomo', 'スポとも！')
on conflict (id) do update set label = excluded.label, active = true;

-- ------------------------------------------------------------
-- 2. sports_goods_exchanges テーブル（スポーツ用品のゆずりあい・交換）
-- ------------------------------------------------------------
create table if not exists public.sports_goods_exchanges (
  id uuid primary key default gen_random_uuid(),
  poster_id uuid not null references auth.users(id) on delete cascade,
  kind text not null check (kind in ('give', 'wanted', 'trade')),
  item_description text not null,           -- 用品名・状態など
  area_name text not null,                 -- 受け渡し希望地域や施設名
  detail text not null default '',          -- 状態・受け渡し方法の自由記述
  photo_path text,                          -- 投稿写真（Storage 'sports-goods-photos' バケットの公開URL）
  location_geohash text not null,
  closed boolean not null default false,    -- 完了（受け渡し・交換が成立した等）
  created_at timestamptz not null default now()
);
create index if not exists sports_goods_exchanges_geohash_idx
  on public.sports_goods_exchanges (location_geohash);

alter table public.sports_goods_exchanges enable row level security;

-- ポリシーの重複対策
drop policy if exists "スポーツ用品のゆずりあい・交換は誰でも閲覧可" on public.sports_goods_exchanges;
drop policy if exists "スポーツ用品のゆずりあい・交換の登録は本人のみ" on public.sports_goods_exchanges;
drop policy if exists "スポーツ用品のゆずりあい・交換の更新は本人のみ" on public.sports_goods_exchanges;
drop policy if exists "スポーツ用品のゆずりあい・交換の削除は本人のみ" on public.sports_goods_exchanges;

create policy "スポーツ用品のゆずりあい・交換は誰でも閲覧可" on public.sports_goods_exchanges
  for select using (true);
create policy "スポーツ用品のゆずりあい・交換の登録は本人のみ" on public.sports_goods_exchanges
  for insert with check (auth.uid() = poster_id);
create policy "スポーツ用品のゆずりあい・交換の更新は本人のみ" on public.sports_goods_exchanges
  for update using (auth.uid() = poster_id);
create policy "スポーツ用品のゆずりあい・交換の削除は本人のみ" on public.sports_goods_exchanges
  for delete using (auth.uid() = poster_id);

-- ゆずりあい・交換の行はアカウント削除で消す
create or replace function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = public, auth, extensions
as $$
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  delete from public.community_members where user_id = auth.uid();
  delete from public.event_participants where user_id = auth.uid();
  delete from public.chat_room_members where user_id = auth.uid();
  delete from public.join_applications where applicant_id = auth.uid();
  delete from public.recruitments where host_id = auth.uid();
  delete from public.communities where owner_id = auth.uid();
  delete from public.categories where created_by = auth.uid();
  delete from public.blocks where blocker_id = auth.uid() or blocked_id = auth.uid();
  delete from public.reports where reporter_id = auth.uid();
  delete from public.catch_reports where reporter_id = auth.uid();
  delete from public.protected_dogs where reporter_id = auth.uid();
  delete from public.protected_cats where reporter_id = auth.uid();
  delete from public.costume_exchanges where poster_id = auth.uid();
  delete from public.parts_exchanges where poster_id = auth.uid();
  delete from public.gear_exchanges where poster_id = auth.uid();
  delete from public.sports_goods_exchanges where poster_id = auth.uid();
  delete from public.profiles where id = auth.uid();

  delete from auth.users where id = auth.uid();
end;
$$;

revoke execute on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;

-- ------------------------------------------------------------
-- 3. 投稿写真バケット（公開）
-- ------------------------------------------------------------
insert into storage.buckets (id, name, public)
values ('sports-goods-photos', 'sports-goods-photos', true)
on conflict (id) do nothing;

-- ポリシーの重複対策
drop policy if exists "用品写真は公開読み取り可" on storage.objects;
drop policy if exists "認証ユーザーは自分の用品写真をアップロード可" on storage.objects;
drop policy if exists "認証ユーザーは自分の用品写真を削除可" on storage.objects;

-- 公開バケットなので誰でも閲覧可（一覧表示に必要）
create policy "用品写真は公開読み取り可" on storage.objects
  for select using (bucket_id = 'sports-goods-photos');

-- アップロードは認証ユーザー本人の名前空間（<uuid>/...）のみ
create policy "認証ユーザーは自分の用品写真をアップロード可" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'sports-goods-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy "認証ユーザーは自分の用品写真を削除可" on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'sports-goods-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

commit;
