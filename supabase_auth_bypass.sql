-- SQL to manually create a bypass user to avoid rate limits
-- Run this in your Supabase SQL Editor

DO $$
DECLARE
  _user_id UUID := 'd1e2b3c4-a5b6-4c7d-8e9f-0a1b2c3d4e5f';
  _user_email TEXT := 'manager@shoptrack.app';
  -- Pre-hashed Password123! using bcrypt (Supabase's default)
  -- If crypt() fails, you may need to enable pgcrypto: CREATE EXTENSION IF NOT EXISTS pgcrypto;
  _hashed_password TEXT := crypt('Password123!', gen_salt('bf'));
BEGIN
  -- 0. CLEANUP existing failed attempts
  DELETE FROM auth.identities WHERE user_id = _user_id;
  DELETE FROM auth.users WHERE id = _user_id OR email = _user_email;

  -- 1. Insert into auth.users with all likely required fields
  INSERT INTO auth.users (
      instance_id, 
      id, 
      aud, 
      role, 
      email, 
      encrypted_password, 
      email_confirmed_at, 
      confirmed_at,
      last_sign_in_at,
      raw_app_meta_data, 
      raw_user_meta_data, 
      is_super_admin,
      is_sso_user,
      created_at, 
      updated_at,
      confirmation_token,
      recovery_token,
      email_change_token_new
  ) VALUES (
      '00000000-0000-0000-0000-000000000000', 
      _user_id, 
      'authenticated', 
      'authenticated', 
      _user_email, 
      _hashed_password, 
      now(), 
      now(),
      now(),
      '{"provider":"email","providers":["email"]}', 
      '{"full_name":"Shop Manager"}',
      false,
      false,
      now(), 
      now(), 
      '', 
      '', 
      ''
  );

  -- 2. Insert into auth.identities
  INSERT INTO auth.identities (
      id, 
      user_id, 
      provider_id,
      identity_data, 
      provider, 
      last_sign_in_at, 
      created_at, 
      updated_at
  ) VALUES (
      _user_id, 
      _user_id, 
      _user_id::text, 
      format('{"sub":"%s","email":"%s"}', _user_id, _user_email)::jsonb,
      'email', 
      now(), 
      now(), 
      now()
  );
END $$;
