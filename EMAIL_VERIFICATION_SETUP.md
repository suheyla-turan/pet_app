# Email Verification Setup Guide

## Problem
Users are not receiving verification emails from the app.

## Root Causes & Solutions

### 1. **Default Firebase Sender Domain Issue** ⚠️
Firebase uses `noreply@firebase.com` by default, which is often flagged as spam.

**Solution:** Configure custom sender domain in Firebase Console

**Steps:**
1. Go to **Firebase Console** → Your Project
2. **Authentication** → **Templates** → **Email address verification**
3. Click on the email template and look for "Sender email"
4. Follow Firebase's guide to configure a custom domain
5. Add SPF and DKIM records to your domain DNS

### 2. **Authorized Domains Not Configured**
The ActionCodeSettings URL might not be recognized as valid.

**Steps:**
1. Go to **Firebase Console** → Your Project
2. **Authentication** → **Settings**
3. Scroll to **Authorized domains**
4. Add your app domain(s):
   - `pati-takip.firebaseapp.com`
   - Your custom domain (if any)
   - localhost (for testing)

### 3. **Email Template Customization**
Customize the email template to be more user-friendly.

**Steps:**
1. **Firebase Console** → **Authentication** → **Templates**
2. **Email address verification** template
3. Customize:
   - Subject line
   - Email body with clear instructions
   - Add app logo/branding

### 4. **Testing Email Delivery**

**From Code Side:**
- App now uses ActionCodeSettings for better deliverability
- Has fallback mechanism: tries ActionCodeSettings first, then standard method
- Shows detailed logging in console

**From User Side:**
```
User sees dialog → "Send Verification Email" button
↓
System attempts ActionCodeSettings method
↓
If fails, falls back to standard sendEmailVerification()
↓
User receives email (should arrive in 5-30 minutes)
↓
User clicks verification link
↓
User refreshes app or taps "Check Verification" button
```

## Current App Configuration

### ActionCodeSettings (In Code)
```dart
ActionCodeSettings(
  url: 'https://pati-takip.firebaseapp.com/verify-email?uid={uid}',
  handleCodeInApp: true,
  iOSBundleId: 'com.example.pati_takip',
  androidPackageName: 'com.example.pati_takip',
  androidInstallApp: true,
)
```

### Email Verification Flow
1. User registers → `registerWithEmailAndPassword()`
2. System calls `sendEmailVerification()` with ActionCodeSettings
3. User stays logged in, sees email verification dialog
4. User can:
   - Click "Send" to resend verification email
   - Click "Check" to verify if email was confirmed
   - Continue using app (with limited features if email not verified)

## Debugging

### Check Logs
Look for these messages in console:
- ✅ `E-posta doğrulama gönderildi` = Email sent successfully
- ⚠️ `ActionCodeSettings ile gönderme başarısız` = ActionCodeSettings failed, fallback used
- ❌ `E-posta doğrulama gönderme hatası` = Email delivery failed completely

### Firebase Console Logs
1. **Firebase Console** → **Authentication** → **Logs**
2. Look for verification email entries
3. Check for any error messages

### Gmail Troubleshooting
If users have Gmail accounts:
- Check **Spam/Promotions** folders
- Verify sender domain is not flagged
- Add sender to contacts to improve deliverability

## Important Notes

⚠️ **Spam Filtering**: Default Firebase domain often lands in spam. Custom domain configuration is recommended for production.

⚠️ **Timing**: Emails can take 5-30 minutes to arrive, depending on ISP and email provider.

⚠️ **Testing**: Use test emails during development. Avoid using personal email accounts that have strict spam filters.

## Next Steps for Production

1. ✅ Configure custom sender domain in Firebase Console
2. ✅ Set up SPF and DKIM DNS records
3. ✅ Customize email template with app branding
4. ✅ Add authorized domains to Firebase
5. ✅ Test with multiple email providers (Gmail, Outlook, Yahoo, etc.)
6. ✅ Monitor Firebase Authentication logs for issues
7. ✅ Set up email delivery monitoring/alerts

## User-Facing Messages

The app now shows clear messages:
- **Turkish (Türkçe)**: "E-posta doğrulama gerekli" with detailed instructions
- **English**: "Email verification required" with detailed instructions
- Users can resend emails if needed
- Users can check verification status anytime
