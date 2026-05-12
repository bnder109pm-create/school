<#
  سكربت نشر تلقائي للمبتدئين (PowerShell)
  ما يفعله:
  - يهيئ مستودع Git محليًا (إن لم يكن موجودًا)
  - يطلب منك تسجيل الدخول عبر GitHub CLI (gh) ويدفع الملفات إلى الريبو البعيد
  - ينصّب Vercel CLI ويشغّل نشر production (تفاعلي أو باستخدام VERCEL_TOKEN)

  كيفية الاستخدام:
  1) افتح PowerShell كـ User
  2) انتقل لمجلد المشروع (المجلد الحالي يجب أن يحتوي على الملفات، مثل index.html)
     مثال: cd 'c:\Users\sloom\OneDrive\Desktop\ban'
  3) شغّل: .\deploy.ps1

  ملاحظة: السكربت يتطلب اتصال إنترنت وتفاعلات بسيطة في المتصفح (لتسجيل الدخول).
#>

$ErrorActionPreference = 'Stop'

function Prompt-YesNo($msg){
    do {
        $ans = Read-Host "$msg (y/n)"
    } while ($ans -notin @('y','n'))
    return $ans -eq 'y'
}

Write-Host "ابدأ تنفيذ خطوات الرفع..." -ForegroundColor Cyan

$repoUrl = 'https://github.com/bnder109pm-create/school.git'

Write-Host "مجلد العمل الحالي: $(Get-Location)" -ForegroundColor Yellow

# تأكد من وجود Git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "Git غير موجود. يُرجى تثبيت Git أولًا: https://git-scm.com/downloads" -ForegroundColor Red
    exit 1
}

# init git repo إذا لم يكن
if (-not (Test-Path .git)) {
    Write-Host "تهيئة مستودع Git محلي..." -ForegroundColor Green
    git init
} else {
    Write-Host "مستودع Git محلي موجود." -ForegroundColor Green
}

Write-Host "إضافة كل الملفات والقيام بcommit (إن لم يكن هناك commit سابق)..." -ForegroundColor Green
git add .
try {
    git commit -m "Initial commit - منصة الكسائي" -q
    Write-Host "تم عمل commit." -ForegroundColor Green
} catch {
    Write-Host "لا توجد تغييرات جديدة للالتزام أو تم الالتزام بالفعل." -ForegroundColor Yellow
}

# تأكد من GitHub CLI
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    Write-Host "GitHub CLI (gh) غير موجود. أنصح بتثبيته لتسهيل المصادقة. هل تريد تثبيته الآن عبر winget؟" -ForegroundColor Yellow
    if (Prompt-YesNo "تثبيت gh عبر winget الآن؟") {
        Write-Host "يحاول تثبيت gh..." -ForegroundColor Green
        winget install --id GitHub.cli -e --silent
    } else {
        Write-Host "ستحتاج لتسجيل الدخول يدوياً عند الدفع (ستُطلب بيانات اعتماد GitHub أو PAT)." -ForegroundColor Yellow
    }
}

Write-Host "سأطلب منك تسجيل الدخول إلى GitHub عبر gh (سيفتح متصفح)." -ForegroundColor Cyan
Write-Host "إذا لم ترغب بذلك، يمكنك إيقاف السكربت (Ctrl+C) ثم تسجيل الدخول يدوياً." -ForegroundColor Yellow
try {
    gh auth login --hostname github.com
} catch {
    Write-Host "خطأ أثناء محاولة تسجيل الدخول عبر gh. يمكنك تجاهل هذا إذا سجلت الدخول بطريقة أخرى." -ForegroundColor Yellow
}

# ربط الريموت
try {
    git remote add origin $repoUrl
    Write-Host "تمت إضافة remote origin -> $repoUrl" -ForegroundColor Green
} catch {
    Write-Host "remote origin قد يكون موجودًا. سيتم تحديث المسار بدلًا من الإضافة." -ForegroundColor Yellow
    git remote set-url origin $repoUrl
}

Write-Host "تعيين اسم الفرع الرئيسي إلى main..." -ForegroundColor Green
git branch -M main

Write-Host "دفع الملفات للريبو البعيد (قد يطلب المتصفح أو PAT)" -ForegroundColor Cyan
try {
    git push -u origin main
    Write-Host "تم دفع الملفات إلى GitHub." -ForegroundColor Green
} catch {
    Write-Host "فشل الدفع التلقائي — حاول الدفع يدوياً أو تحقق من صلاحيات الوصول." -ForegroundColor Red
    Write-Host "يمكنك تشغيل: git push -u origin main" -ForegroundColor Yellow
}

# نشر إلى Vercel
Write-Host "\n---\nالآن خطوة النشر إلى Vercel." -ForegroundColor Cyan
if (-not (Get-Command vercel -ErrorAction SilentlyContinue)) {
    Write-Host "Vercel CLI غير مثبت. سيتم تثبيته الآن (قد يحتاج صلاحيات)." -ForegroundColor Green
    npm install -g vercel
}

if (Prompt-YesNo "هل تريد استخدام Vercel عبر token (أنصح به) بدل الدخول التفاعلي؟ اذا لا سيتم فتح عملية تسجيل تفاعلية في المتصفح.") {
    $token = Read-Host "أدخل Vercel Personal Token (لن يُعرض)" -AsSecureString
    $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($token)
    $plainToken = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    try { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr) } catch {}

    Write-Host "نشر باستخدام التوكن..." -ForegroundColor Green
    npx vercel --prod --token $plainToken
} else {
    Write-Host "سيتم فتح عملية تسجيل/نشر تفاعلية عبر Vercel CLI (سيفتح المتصفح إن لزم)." -ForegroundColor Cyan
    npx vercel --prod
}

Write-Host "\nاكتملت الخطوات الأساسية. تفقد GitHub وVercel لرؤية النتيجة." -ForegroundColor Green
Write-Host "إذا ظهرت أخطاء، انسخ الرسالة وأرسلها لي لأساعدك بالتعديل." -ForegroundColor Cyan
