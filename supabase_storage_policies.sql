-- ============================================================
-- Faith Klinik — Supabase Storage Policies for church-media
-- ============================================================
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- This fixes the 403 "row level security" error on uploads.
-- ============================================================

-- 1. Make the bucket public (images load without auth tokens)
UPDATE storage.buckets
SET public = true
WHERE id = 'church-media';

-- 2. Allow anyone (anon + authenticated) to READ files
DROP POLICY IF EXISTS "Public read church-media" ON storage.objects;
CREATE POLICY "Public read church-media"
ON storage.objects FOR SELECT
USING (bucket_id = 'church-media');

-- 3. Allow authenticated users to UPLOAD (INSERT)
DROP POLICY IF EXISTS "Auth upload church-media" ON storage.objects;
CREATE POLICY "Auth upload church-media"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (bucket_id = 'church-media');

-- 4. Allow authenticated users to UPDATE (upsert overwrites)
DROP POLICY IF EXISTS "Auth update church-media" ON storage.objects;
CREATE POLICY "Auth update church-media"
ON storage.objects FOR UPDATE
TO authenticated
USING (bucket_id = 'church-media');

-- 5. Allow authenticated users to DELETE
DROP POLICY IF EXISTS "Auth delete church-media" ON storage.objects;
CREATE POLICY "Auth delete church-media"
ON storage.objects FOR DELETE
TO authenticated
USING (bucket_id = 'church-media');
