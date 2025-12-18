$path = "c:\Users\USER\Desktop\lumenvestasset.com"
$files = Get-ChildItem -Path $path -Include *.html,*.htm -Recurse

$animStyle = @"
<style>
  /* Scroll Animation Classes */
  .scroll-hidden {
    opacity: 0;
    transition: all 1s ease-out;
  }
  .scroll-from-left {
    transform: translateX(-100px);
  }
  .scroll-from-right {
    transform: translateX(100px);
  }
  .scroll-visible {
    opacity: 1;
    transform: translateX(0) !important;
  }
  /* Ensure no overflow during animation */
  body {
    overflow-x: hidden;
  }
</style>
"@

$animScript = @"
<script>
  document.addEventListener('DOMContentLoaded', function() {
    // Select direct children of main, or sections if main missing
    let targets = document.querySelectorAll('main > section, main > div');
    if (targets.length === 0) {
      targets = document.querySelectorAll('body > section');
    }
    
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('scroll-visible');
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.1 }); // Trigger when 10% visible

    targets.forEach((el, index) => {
      el.classList.add('scroll-hidden');
      if (index % 2 === 0) {
        el.classList.add('scroll-from-left'); // Even: From Left
      } else {
        el.classList.add('scroll-from-right'); // Odd: From Right
      }
      observer.observe(el);
    });
  });
</script>
"@

foreach ($file in $files) {
    Write-Host "Processing $($file.Name)..."
    $content = Get-Content $file.FullName -Raw
    
    # Avoid duplicate injection
    if ($content -match "scroll-visible") {
        Write-Host "Skipping $($file.Name) (already matches)"
        continue
    }

    # Inject before </body>
    if ($content -match "</body>") {
        $content = $content -replace "</body>", "$animStyle`n$animScript`n</body>"
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
    } else {
        Write-Host "Warning: No </body> tag in $($file.Name)"
    }
}
Write-Host "Animation Injection Complete!"
