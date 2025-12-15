# Fix GitHub Pages deployment for Flutter (PowerShell)

Write-Host "🔧 Fixing GitHub Pages deployment for Flutter..." -ForegroundColor Cyan

function Write-Status { param([string]$Message) Write-Host "[INFO] $Message" -ForegroundColor Cyan }
function Write-Success { param([string]$Message) Write-Host "[SUCCESS] $Message" -ForegroundColor Green }
function Write-Warning { param([string]$Message) Write-Host "[WARNING] $Message" -ForegroundColor Yellow }
function Write-Error { param([string]$Message) Write-Host "[ERROR] $Message" -ForegroundColor Red }

# Step 1: Clean and prepare
Write-Status "Step 1: Cleaning previous builds..."
flutter clean
flutter pub get

# Step 2: Build with specific GitHub Pages optimizations
Write-Status "Step 2: Building for GitHub Pages with optimizations..."
flutter build web --release --base-href "/todo_cleanarc/" --dart-define=FLUTTER_WEB_USE_SKIA=false --dart-define=FLUTTER_WEB_AUTO_DETECT=false

# Step 3: Fix common GitHub Pages issues
Write-Status "Step 3: Applying GitHub Pages fixes..."

# Create a simple .nojekyll file to prevent Jekyll processing
New-Item -Path "build/web/.nojekyll" -ItemType File -Force | Out-Null

# Fix the index.html for better GitHub Pages compatibility
$indexHtml = @'
<!DOCTYPE html>
<html>
<head>
  <base href="/todo_cleanarc/">
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="description" content="TaskFlow - A powerful task management app">
  <meta name="apple-mobile-web-app-capable" content="yes">
  <meta name="apple-mobile-web-app-status-bar-style" content="black">
  <meta name="apple-mobile-web-app-title" content="TaskFlow">
  <link rel="apple-touch-icon" href="icons/Icon-192.png">
  <link rel="icon" type="image/png" href="favicon.png"/>
  <title>TaskFlow</title>
  <link rel="manifest" href="manifest.json">
  
  <!-- GitHub Pages SPA fix -->
  <script type="text/javascript">
    (function(l) {
      if (l.search[1] === '/' ) {
        var decoded = l.search.slice(1).split('&').map(function(s) { 
          return s.replace(/~and~/g, '&')
        }).join('?');
        window.history.replaceState(null, null,
            l.pathname.slice(0, -1) + decoded + l.hash
        );
      }
    }(window.location))
  </script>
  
  <style>
    body {
      margin: 0;
      padding: 0;
      background: #f5f5f5;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    }
    .loading {
      position: fixed;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%);
      text-align: center;
    }
    .spinner {
      border: 4px solid #f3f3f3;
      border-top: 4px solid #3498db;
      border-radius: 50%;
      width: 40px;
      height: 40px;
      animation: spin 2s linear infinite;
      margin: 0 auto 20px;
    }
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
  </style>
</head>
<body>
  <div class="loading" id="loading">
    <div class="spinner"></div>
    <p>Loading TaskFlow...</p>
  </div>
  
  <script>
    window.addEventListener('load', function(ev) {
      _flutter.loader.load({
        serviceWorkerSettings: {
          serviceWorkerVersion: null,
        },
        onEntrypointLoaded: function(engineInitializer) {
          engineInitializer.initializeEngine().then(function(appRunner) {
            document.getElementById('loading').style.display = 'none';
            appRunner.runApp();
          });
        }
      });
    });
  </script>
  <script src="flutter.js" defer></script>
</body>
</html>
'@

$indexHtml | Out-File -FilePath "build/web/index.html" -Encoding UTF8

# Step 4: Create deployment instructions
Write-Status "Step 4: Creating deployment instructions..."

$deployInstructions = @'
# Deploy to GitHub Pages

## Quick Deploy Steps:

1. **Manual method (easiest):**
   - Go to your repository on GitHub
   - Switch to `gh-pages` branch (create if doesn't exist)
   - Upload all files from `build/web/` folder
   - Commit and push

2. **Using git subtree:**
   ```bash
   git subtree push --prefix build/web origin gh-pages
   ```

## Verify Deployment:
- Wait 5-10 minutes
- Visit: https://uumair327.github.io/todo_cleanarc/
- Check browser console (F12) for errors

## If still blank:
1. Check GitHub Pages settings (Settings → Pages)
2. Ensure source is set to `gh-pages` branch
3. Clear browser cache (Ctrl+F5)
4. Check if files exist: https://uumair327.github.io/todo_cleanarc/main.dart.js
'@

$deployInstructions | Out-File -FilePath "DEPLOY_TO_GITHUB_PAGES.md" -Encoding UTF8

Write-Success "Build completed with GitHub Pages optimizations!"
Write-Status "Build location: build/web/"
Write-Status "Files ready for deployment:"
Get-ChildItem -Path "build/web/" | Format-Table Name, Length, LastWriteTime

Write-Warning "Next steps:"
Write-Host "1. Deploy the build/web/ contents to your gh-pages branch"
Write-Host "2. Check DEPLOY_TO_GITHUB_PAGES.md for detailed instructions"
Write-Host "3. Your app will be available at: https://uumair327.github.io/todo_cleanarc/"

Write-Success "GitHub Pages fix script completed!"