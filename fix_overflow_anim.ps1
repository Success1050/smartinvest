$path = "c:\Users\USER\Desktop\lumenvestasset.com"
$files = Get-ChildItem -Path $path -Include *.html,*.htm -Recurse

$newBlock = @"
<style>
  /* Fix Mobile Overflow */
  html, body {
    overflow-x: hidden !important;
    width: 100%;
    margin: 0;
    padding: 0;
  }
  
  /* Scroll Animation Classes */
  .scroll-hidden {
    opacity: 0;
    transition: all 1.0s ease-out;
  }
  
  /* Desktop: Larger Movement */
  .scroll-from-left {
    transform: translateX(-50px);
  }
  .scroll-from-right {
    transform: translateX(50px);
  }
  .scroll-visible {
    opacity: 1;
    transform: translateX(0) !important;
  }
  
  /* Mobile: Reduced Movement to prevent horizontal scrollbars */
  @media (max-width: 768px) {
    .scroll-from-left {
      transform: translateX(-15px);
    }
    .scroll-from-right {
      transform: translateX(15px);
    }
  }
</style>
<script>
  document.addEventListener('DOMContentLoaded', function() {
    // Select direct children of main
    let targets = document.querySelectorAll('main > section, main > div');
    if (targets.length === 0) {
      targets = document.querySelectorAll('body > section');
    }
    
    // Intersection Observer
    const observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('scroll-visible');
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.1 });

    targets.forEach((el, index) => {
      // Clean up previous classes if present
      el.classList.remove('scroll-hidden', 'scroll-from-left', 'scroll-from-right', 'scroll-visible');
      
      // Add new animation classes
      el.classList.add('scroll-hidden');
      if (index % 2 === 0) {
        el.classList.add('scroll-from-left');
      } else {
        el.classList.add('scroll-from-right');
      }
      observer.observe(el);
    });
  });
</script>
"@

foreach ($file in $files) {
    Write-Host "Updating $($file.Name)..."
    $content = Get-Content $file.FullName -Raw
    
    # 1. Remove OLD Block (Regex match for the previous injection)
    #    Matches from <style>.../* Scroll Animation Classes */...</script>
    $content = [Regex]::Replace($content, '(?s)<style>\s*/\* Scroll Animation Classes \*/.*?</script>', '')
    
    # 2. Inject NEW Block before </body>
    if ($content -match "</body>") {
        $content = $content -replace "</body>", "$newBlock`n</body>"
    }
    
    Set-Content -Path $file.FullName -Value $content -Encoding UTF8
}
Write-Host "Overflow Fix Applied!"
