-- ================================================================
-- FAITH KLINIK MINISTRIES — Full Supabase Setup
-- ================================================================
-- Run in: Supabase Dashboard → SQL Editor → New Query
-- Safe to re-run: uses IF NOT EXISTS / ON CONFLICT throughout.
-- ================================================================


-- ================================================================
-- 1. STORAGE BUCKET
-- ================================================================

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('church-media', 'church-media', true, 104857600, null)
ON CONFLICT (id) DO UPDATE SET public = true, file_size_limit = 104857600;

-- Public read (all files in bucket)
DROP POLICY IF EXISTS "fk_public_read" ON storage.objects;
CREATE POLICY "fk_public_read"
ON storage.objects FOR SELECT
USING (bucket_id = 'church-media');

-- Authenticated upload
DROP POLICY IF EXISTS "fk_auth_insert" ON storage.objects;
CREATE POLICY "fk_auth_insert"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'church-media');

-- Authenticated overwrite (upsert)
DROP POLICY IF EXISTS "fk_auth_update" ON storage.objects;
CREATE POLICY "fk_auth_update"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'church-media');

-- Authenticated delete
DROP POLICY IF EXISTS "fk_auth_delete" ON storage.objects;
CREATE POLICY "fk_auth_delete"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'church-media');


-- ================================================================
-- 2. USERS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.users (
  id           uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email        text NOT NULL DEFAULT '',
  name         text NOT NULL DEFAULT '',
  phone        text DEFAULT '',
  role         text NOT NULL DEFAULT 'member'
                 CHECK (role IN ('pastor','admin','dept_head','department_head','media_team','treasurer','member','child')),
  department   text DEFAULT '',
  join_date    date,
  status       text NOT NULL DEFAULT 'active'
);

ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "users_read"   ON public.users;
DROP POLICY IF EXISTS "users_own_write" ON public.users;
DROP POLICY IF EXISTS "users_admin_write" ON public.users;

CREATE POLICY "users_read"        ON public.users FOR SELECT USING (true);
CREATE POLICY "users_own_write"   ON public.users FOR UPDATE USING (auth.uid()::text = id::text);
CREATE POLICY "users_own_insert"  ON public.users FOR INSERT WITH CHECK (auth.uid()::text = id::text);


-- ================================================================
-- 3. BANNERS (hero / children's / campaign slides)
-- ================================================================

CREATE TABLE IF NOT EXISTS public.banners (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title       text NOT NULL DEFAULT '',
  subtitle    text DEFAULT '',
  media_url   text DEFAULT '',
  media_type  text DEFAULT 'none',
  link_route  text DEFAULT '',
  is_active   boolean NOT NULL DEFAULT true,
  sort_order  integer NOT NULL DEFAULT 0,
  audience    text NOT NULL DEFAULT 'adult'
                CHECK (audience IN ('adult','children','campaign')),
  created_at  timestamptz DEFAULT now()
);

ALTER TABLE public.banners ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "banners_read"  ON public.banners;
DROP POLICY IF EXISTS "banners_write" ON public.banners;

CREATE POLICY "banners_read"  ON public.banners FOR SELECT USING (true);
CREATE POLICY "banners_write" ON public.banners FOR ALL TO authenticated USING (true);


-- ================================================================
-- 4. ANNOUNCEMENTS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.announcements (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title       text NOT NULL DEFAULT '',
  content     text DEFAULT '',
  priority    text DEFAULT 'Normal' CHECK (priority IN ('High','Normal','Low')),
  author      text DEFAULT '',
  date        timestamptz DEFAULT now(),
  department  text DEFAULT '',
  status      text DEFAULT 'active',
  audience    text DEFAULT 'all',
  media_url   text DEFAULT ''
);

ALTER TABLE public.announcements ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "ann_read"  ON public.announcements;
DROP POLICY IF EXISTS "ann_write" ON public.announcements;

CREATE POLICY "ann_read"  ON public.announcements FOR SELECT USING (true);
CREATE POLICY "ann_write" ON public.announcements FOR ALL TO authenticated USING (true);


-- ================================================================
-- 5. EVENTS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.events (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title         text NOT NULL DEFAULT '',
  date          date NOT NULL,
  time          text DEFAULT '',
  location      text DEFAULT '',
  type          text DEFAULT 'General',
  status        text DEFAULT 'Upcoming',
  cover_url     text DEFAULT '',
  streaming_url text DEFAULT '',
  created_at    timestamptz DEFAULT now()
);

ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "events_read"  ON public.events;
DROP POLICY IF EXISTS "events_write" ON public.events;

CREATE POLICY "events_read"  ON public.events FOR SELECT USING (true);
CREATE POLICY "events_write" ON public.events FOR ALL TO authenticated USING (true);


-- ================================================================
-- 6. SERMONS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.sermons (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title       text NOT NULL DEFAULT '',
  speaker     text DEFAULT '',
  date        timestamptz DEFAULT now(),
  file_path   text DEFAULT '',
  file_url    text DEFAULT '',
  file_type   text DEFAULT 'audio',
  description text DEFAULT '',
  audience    text DEFAULT 'all',
  created_at  timestamptz DEFAULT now()
);

ALTER TABLE public.sermons ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "sermons_read"  ON public.sermons;
DROP POLICY IF EXISTS "sermons_write" ON public.sermons;

CREATE POLICY "sermons_read"  ON public.sermons FOR SELECT USING (true);
CREATE POLICY "sermons_write" ON public.sermons FOR ALL TO authenticated USING (true);


-- ================================================================
-- 7. LIVE STREAMS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.live_streams (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title        text NOT NULL DEFAULT '',
  date         date DEFAULT CURRENT_DATE,
  time         text DEFAULT '',
  status       text DEFAULT 'upcoming',
  viewers      integer DEFAULT 0,
  category     text DEFAULT '',
  stream_url   text DEFAULT '',
  platform     text DEFAULT '',
  platform_url text DEFAULT '',
  description  text DEFAULT ''
);

ALTER TABLE public.live_streams ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "streams_read"  ON public.live_streams;
DROP POLICY IF EXISTS "streams_write" ON public.live_streams;

CREATE POLICY "streams_read"  ON public.live_streams FOR SELECT USING (true);
CREATE POLICY "streams_write" ON public.live_streams FOR ALL TO authenticated USING (true);


-- ================================================================
-- 8. CHURCH LIBRARY
-- ================================================================

CREATE TABLE IF NOT EXISTS public.church_library (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title       text NOT NULL DEFAULT '',
  author      text DEFAULT '',
  description text DEFAULT '',
  type        text DEFAULT 'book'
                CHECK (type IN ('book','plan','pdf','audio','video','link')),
  file_url    text DEFAULT '',
  created_at  timestamptz DEFAULT now()
);

ALTER TABLE public.church_library ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "lib_read"  ON public.church_library;
DROP POLICY IF EXISTS "lib_write" ON public.church_library;

CREATE POLICY "lib_read"  ON public.church_library FOR SELECT USING (true);
CREATE POLICY "lib_write" ON public.church_library FOR ALL TO authenticated USING (true);


-- ================================================================
-- 9. CHURCH GROUPS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.church_groups (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name           text NOT NULL DEFAULT '',
  description    text DEFAULT '',
  leader         text DEFAULT '',
  leaders        text[] DEFAULT '{}',
  members        text[] DEFAULT '{}',
  meeting_day    text DEFAULT '',
  meeting_time   text DEFAULT '',
  location       text DEFAULT '',
  whatsapp_group text DEFAULT '',
  cover_url      text DEFAULT '',
  created_at     timestamptz DEFAULT now()
);

ALTER TABLE public.church_groups ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "groups_read"  ON public.church_groups;
DROP POLICY IF EXISTS "groups_write" ON public.church_groups;

CREATE POLICY "groups_read"  ON public.church_groups FOR SELECT USING (true);
CREATE POLICY "groups_write" ON public.church_groups FOR ALL TO authenticated USING (true);


-- ================================================================
-- 10. GROUP DUES
-- ================================================================

CREATE TABLE IF NOT EXISTS public.dues_entries (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id    uuid REFERENCES public.church_groups(id) ON DELETE CASCADE,
  member_name text DEFAULT '',
  amount      numeric(10,2) DEFAULT 0,
  date        timestamptz DEFAULT now(),
  period      text DEFAULT '',
  note        text DEFAULT '',
  posted_by   text DEFAULT ''
);

ALTER TABLE public.dues_entries ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "dues_read"  ON public.dues_entries;
DROP POLICY IF EXISTS "dues_write" ON public.dues_entries;

CREATE POLICY "dues_read"  ON public.dues_entries FOR SELECT TO authenticated USING (true);
CREATE POLICY "dues_write" ON public.dues_entries FOR ALL TO authenticated USING (true);


-- ================================================================
-- 11. GROUP FINANCES
-- ================================================================

CREATE TABLE IF NOT EXISTS public.group_finances (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id   uuid REFERENCES public.church_groups(id) ON DELETE CASCADE,
  title      text DEFAULT '',
  body       text DEFAULT '',
  amount     numeric(10,2) DEFAULT 0,
  date       timestamptz DEFAULT now(),
  posted_by  text DEFAULT '',
  category   text DEFAULT ''
);

ALTER TABLE public.group_finances ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "gfin_read"  ON public.group_finances;
DROP POLICY IF EXISTS "gfin_write" ON public.group_finances;

CREATE POLICY "gfin_read"  ON public.group_finances FOR SELECT TO authenticated USING (true);
CREATE POLICY "gfin_write" ON public.group_finances FOR ALL TO authenticated USING (true);


-- ================================================================
-- 12. CHURCH FINANCES (giving / tithing)
-- ================================================================

CREATE TABLE IF NOT EXISTS public.finances (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  type        text DEFAULT 'Tithe',
  amount      numeric(12,2) NOT NULL DEFAULT 0,
  member_name text DEFAULT '',
  date        date DEFAULT CURRENT_DATE,
  method      text DEFAULT 'Cash',
  status      text DEFAULT 'Completed',
  department  text DEFAULT '',
  created_at  timestamptz DEFAULT now()
);

ALTER TABLE public.finances ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "fin_read"  ON public.finances;
DROP POLICY IF EXISTS "fin_write" ON public.finances;

CREATE POLICY "fin_read"  ON public.finances FOR SELECT TO authenticated USING (true);
CREATE POLICY "fin_write" ON public.finances FOR ALL TO authenticated USING (true);


-- ================================================================
-- 13. MEMBERSHIPS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.memberships (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     uuid REFERENCES public.users(id) ON DELETE CASCADE,
  type        text DEFAULT 'Regular',
  status      text DEFAULT 'active',
  start_date  date DEFAULT CURRENT_DATE,
  expiry_date date,
  benefits    text[] DEFAULT '{}'
);

ALTER TABLE public.memberships ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "mem_read"  ON public.memberships;
DROP POLICY IF EXISTS "mem_write" ON public.memberships;

CREATE POLICY "mem_read"  ON public.memberships FOR SELECT TO authenticated USING (true);
CREATE POLICY "mem_write" ON public.memberships FOR ALL TO authenticated USING (true);


-- ================================================================
-- 14. PRAYER REQUESTS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.prayer_requests (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title       text NOT NULL DEFAULT '',
  member_name text DEFAULT '',
  request     text DEFAULT '',
  category    text DEFAULT 'General',
  status      text DEFAULT 'active',
  date        timestamptz DEFAULT now(),
  private     boolean DEFAULT false,
  responses   integer DEFAULT 0
);

ALTER TABLE public.prayer_requests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "prayer_read"  ON public.prayer_requests;
DROP POLICY IF EXISTS "prayer_write" ON public.prayer_requests;

CREATE POLICY "prayer_read"  ON public.prayer_requests FOR SELECT USING (true);
CREATE POLICY "prayer_write" ON public.prayer_requests FOR ALL TO authenticated USING (true);


-- ================================================================
-- 15. MEMBER NOTES (sermon notes)
-- ================================================================

CREATE TABLE IF NOT EXISTS public.member_notes (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        uuid REFERENCES public.users(id) ON DELETE CASCADE,
  sermon_title   text DEFAULT '',
  key_passage    text DEFAULT '',
  theme          text DEFAULT '',
  application    text DEFAULT '',
  notes          text DEFAULT '',
  sermon_points  text[] DEFAULT '{}',
  prayer_points  text[] DEFAULT '{}',
  created_at     timestamptz DEFAULT now(),
  updated_at     timestamptz DEFAULT now()
);

ALTER TABLE public.member_notes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "notes_own" ON public.member_notes;

CREATE POLICY "notes_own" ON public.member_notes FOR ALL TO authenticated
  USING (auth.uid()::text = user_id::text)
  WITH CHECK (auth.uid()::text = user_id::text);


-- ================================================================
-- 16. NOTIFICATIONS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.notifications (
  id       uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id  uuid REFERENCES public.users(id) ON DELETE CASCADE,
  title    text DEFAULT '',
  message  text DEFAULT '',
  type     text DEFAULT 'info',
  read     boolean DEFAULT false,
  date     timestamptz DEFAULT now()
);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "notif_own" ON public.notifications;

CREATE POLICY "notif_own" ON public.notifications FOR ALL TO authenticated
  USING (auth.uid()::text = user_id::text)
  WITH CHECK (auth.uid()::text = user_id::text);


-- ================================================================
-- 17. STAFF MEMBERS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.staff_members (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name        text NOT NULL DEFAULT '',
  title       text DEFAULT '',
  department  text DEFAULT '',
  image_url   text DEFAULT '',
  bio         text DEFAULT '',
  sort_order  integer DEFAULT 0,
  email       text DEFAULT '',
  phone       text DEFAULT ''
);

ALTER TABLE public.staff_members ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "staff_read"  ON public.staff_members;
DROP POLICY IF EXISTS "staff_write" ON public.staff_members;

CREATE POLICY "staff_read"  ON public.staff_members FOR SELECT USING (true);
CREATE POLICY "staff_write" ON public.staff_members FOR ALL TO authenticated USING (true);


-- ================================================================
-- 18. BULLETINS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.bulletins (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title      text DEFAULT 'Weekly Bulletin',
  content    jsonb DEFAULT '{}',
  date       date DEFAULT CURRENT_DATE,
  active     boolean DEFAULT true,
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE public.bulletins ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "bull_read"  ON public.bulletins;
DROP POLICY IF EXISTS "bull_write" ON public.bulletins;

CREATE POLICY "bull_read"  ON public.bulletins FOR SELECT USING (true);
CREATE POLICY "bull_write" ON public.bulletins FOR ALL TO authenticated USING (true);


-- ================================================================
-- 19. EVENT PHOTOS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.event_photos (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title         text DEFAULT '',
  description   text DEFAULT '',
  image_url     text NOT NULL DEFAULT '',
  uploaded_by   text DEFAULT '',
  uploader_name text DEFAULT '',
  department    text DEFAULT '',
  uploaded_at   timestamptz DEFAULT now(),
  event_name    text DEFAULT '',
  event_date    date,
  is_public     boolean DEFAULT true
);

ALTER TABLE public.event_photos ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "photos_read"  ON public.event_photos;
DROP POLICY IF EXISTS "photos_write" ON public.event_photos;

CREATE POLICY "photos_read"  ON public.event_photos FOR SELECT USING (true);
CREATE POLICY "photos_write" ON public.event_photos FOR ALL TO authenticated USING (true);


-- ================================================================
-- 20. CHILDREN'S LESSONS (Bible Stories)
-- ================================================================

CREATE TABLE IF NOT EXISTS public.child_lessons (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title        text NOT NULL DEFAULT '',
  content      text DEFAULT '',
  duration     text DEFAULT '',
  age_range    text DEFAULT '',
  completed    boolean DEFAULT false,
  scripture_ref text DEFAULT '',
  created_at   timestamptz DEFAULT now()
);

ALTER TABLE public.child_lessons ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "cl_read"  ON public.child_lessons;
DROP POLICY IF EXISTS "cl_write" ON public.child_lessons;

CREATE POLICY "cl_read"  ON public.child_lessons FOR SELECT USING (true);
CREATE POLICY "cl_write" ON public.child_lessons FOR ALL TO authenticated USING (true);


-- ================================================================
-- 21. CHILDREN'S SERMONS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.child_sermons (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title      text NOT NULL DEFAULT '',
  speaker    text DEFAULT '',
  date       date DEFAULT CURRENT_DATE,
  duration   text DEFAULT '',
  views      integer DEFAULT 0,
  video_url  text DEFAULT '',
  created_at timestamptz DEFAULT now()
);

ALTER TABLE public.child_sermons ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "cs_read"  ON public.child_sermons;
DROP POLICY IF EXISTS "cs_write" ON public.child_sermons;

CREATE POLICY "cs_read"  ON public.child_sermons FOR SELECT USING (true);
CREATE POLICY "cs_write" ON public.child_sermons FOR ALL TO authenticated USING (true);


-- ================================================================
-- 22. CHILDREN'S GAMES
-- ================================================================

CREATE TABLE IF NOT EXISTS public.child_games (
  id          uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title       text NOT NULL DEFAULT '',
  description text DEFAULT '',
  difficulty  text DEFAULT 'Easy',
  completed   boolean DEFAULT false
);

ALTER TABLE public.child_games ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "cg_read"  ON public.child_games;
DROP POLICY IF EXISTS "cg_write" ON public.child_games;

CREATE POLICY "cg_read"  ON public.child_games FOR SELECT USING (true);
CREATE POLICY "cg_write" ON public.child_games FOR ALL TO authenticated USING (true);


-- ================================================================
-- 23. CHILD LESSON PROGRESS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.child_lesson_progress (
  lesson_id    uuid REFERENCES public.child_lessons(id) ON DELETE CASCADE,
  child_id     text NOT NULL,
  completed    boolean DEFAULT false,
  completed_at timestamptz,
  PRIMARY KEY (lesson_id, child_id)
);

ALTER TABLE public.child_lesson_progress ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "clp_all" ON public.child_lesson_progress;
CREATE POLICY "clp_all" ON public.child_lesson_progress FOR ALL TO authenticated USING (true);


-- ================================================================
-- 24. CHILD GAME PROGRESS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.child_game_progress (
  game_id      uuid REFERENCES public.child_games(id) ON DELETE CASCADE,
  child_id     text NOT NULL,
  completed    boolean DEFAULT false,
  completed_at timestamptz,
  PRIMARY KEY (game_id, child_id)
);

ALTER TABLE public.child_game_progress ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "cgp_all" ON public.child_game_progress;
CREATE POLICY "cgp_all" ON public.child_game_progress FOR ALL TO authenticated USING (true);


-- ================================================================
-- 25. CHILD ACCOUNTS
-- ================================================================

CREATE TABLE IF NOT EXISTS public.child_accounts (
  id             uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_user_id uuid REFERENCES public.users(id) ON DELETE CASCADE,
  account_name   text NOT NULL DEFAULT '',
  pin            text DEFAULT '',
  avatar_url     text DEFAULT '',
  age_years      integer DEFAULT 0,
  created_at     timestamptz DEFAULT now()
);

ALTER TABLE public.child_accounts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "ca_own" ON public.child_accounts;
CREATE POLICY "ca_own" ON public.child_accounts FOR ALL TO authenticated
  USING (auth.uid()::text = parent_user_id::text)
  WITH CHECK (auth.uid()::text = parent_user_id::text);


-- ================================================================
-- Done. All tables created with RLS enabled and policies set.
-- The church-media storage bucket is public and ready for uploads.
-- ================================================================
