-- ============================================================
-- Faith Klinik — Supabase Storage Setup for church-media
-- ============================================================
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- Run it ONCE. Safe to re-run (uses ON CONFLICT / DROP IF EXISTS).
-- ============================================================

-- 1. Create the bucket if it doesn't exist, make it public
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('church-media', 'church-media', true, 104857600, null)
ON CONFLICT (id) DO UPDATE SET public = true, file_size_limit = 104857600;

-- 2. Allow anyone to READ files (needed for public image URLs to load)
DROP POLICY IF EXISTS "Public read church-media" ON storage.objects;
CREATE POLICY "Public read church-media"
ON storage.objects FOR SELECT
USING (bucket_id = 'church-media');

-- 3. Allow logged-in users to UPLOAD files
DROP POLICY IF EXISTS "Auth upload church-media" ON storage.objects;
CREATE POLICY "Auth upload church-media"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'church-media');

-- 4. Allow logged-in users to OVERWRITE files (upsert)
DROP POLICY IF EXISTS "Auth update church-media" ON storage.objects;
CREATE POLICY "Auth update church-media"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'church-media');

-- 5. Allow logged-in users to DELETE files
DROP POLICY IF EXISTS "Auth delete church-media" ON storage.objects;
CREATE POLICY "Auth delete church-media"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'church-media');
