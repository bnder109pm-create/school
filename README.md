# تعليمات نشر الموقع - منصة الكسائي

هذا مشروع موقع ثابت بسيط (ملف `index.html`) مخصّص لثانوية الكسائي. هذا الملف يوضح كيفية نشر المشروع على Vercel خطوة بخطوة باستخدام PowerShell على نظام Windows.

## ما يهمك كطالب ثانوي (بسيط وسريع)
- المشروع جاهز للنشر: الملف `index.html` هو صفحة الويب.
- استخدم Vercel لنشر الموقع بسرعة (يعطيك رابط إنترنت تلقائيًا).

## خطوات سريعة (PowerShell)
1. ثبت Node.js و npm إن لم تكن مثبتة.
2. افتح PowerShell وركّز على مجلد المشروع:

```powershell
cd 'c:\Users\sloom\OneDrive\Desktop\ban'
```

3. ثبّت Vercel CLI:

```powershell
npm install -g vercel
```

4. سجل دخول إلى حساب Vercel (سيفتح المتصفح):

```powershell
vercel login
```

5. نفّذ نشر سريع:

```powershell
vercel --prod
```

بعد الانتهاء سيعطيك Vercel رابط الموقع.

## طريقة آمنة لاستخدام GitHub Actions
1. أنشئ Repo على GitHub وارفع الملفات.
2. في إعدادات الريبو (Settings → Secrets)، أضف `VERCEL_TOKEN` بقيمة توكنك من Vercel.
3. يمكنك استخدام الworkflow الموجود في `.github/workflows/vercel-deploy.yml` لنشر تلقائي عند كل دفع إلى `main`.
