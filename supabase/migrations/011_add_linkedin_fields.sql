-- Migration 011: Add LinkedIn integration fields to profiles
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS linkedin_id TEXT,
ADD COLUMN IF NOT EXISTS linkedin_avatar_url TEXT,
ADD COLUMN IF NOT EXISTS linkedin_headline TEXT,
ADD COLUMN IF NOT EXISTS linkedin_sync_avatar BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN IF NOT EXISTS linkedin_verified BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN IF NOT EXISTS linkedin_posts JSONB NOT NULL DEFAULT '[]'::jsonb;

COMMENT ON COLUMN public.profiles.linkedin_id IS 'Unique identifier or sub from LinkedIn OpenID Connect';
COMMENT ON COLUMN public.profiles.linkedin_avatar_url IS 'High-res profile photo URL fetched from LinkedIn CDN';
COMMENT ON COLUMN public.profiles.linkedin_headline IS 'Professional headline or current job title from LinkedIn profile';
COMMENT ON COLUMN public.profiles.linkedin_sync_avatar IS 'Flag indicating whether member uses LinkedIn photo as primary CITT Connect avatar';
COMMENT ON COLUMN public.profiles.linkedin_verified IS 'True if profile identity was linked and verified via LinkedIn OAuth/OIDC';
COMMENT ON COLUMN public.profiles.linkedin_posts IS 'Array of featured LinkedIn post embeds and activities';
