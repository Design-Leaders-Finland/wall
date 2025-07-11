// This script handles theme-aware icons for web
(function() {
  // Check if the browser supports dark mode
  const prefersDarkScheme = window.matchMedia('(prefers-color-scheme: dark)');
  
  // Function to set the appropriate icons based on the theme
  function setThemeIcons(isDark) {
    // Icons for web manifest
    const icons = document.querySelectorAll('link[rel="icon"], link[rel="apple-touch-icon"]');
    
    icons.forEach(icon => {
      const iconHref = icon.getAttribute('href');
      if (iconHref) {
        // If dark mode, use -dark icon versions
        if (isDark) {
          if (iconHref.includes('favicon.png')) {
            icon.setAttribute('href', 'favicon-dark.png');
          } else if (iconHref.includes('Icon-')) {
            const darkIconHref = iconHref.replace('Icon-', 'Icon-dark-');
            icon.setAttribute('href', darkIconHref);
          }
        } 
        // If light mode, ensure we're using standard icons
        else {
          if (iconHref.includes('favicon-dark.png')) {
            icon.setAttribute('href', 'favicon.png');
          } else if (iconHref.includes('Icon-dark-')) {
            const lightIconHref = iconHref.replace('Icon-dark-', 'Icon-');
            icon.setAttribute('href', lightIconHref);
          }
        }
      }
    });
  }
  
  // Set initial icons based on the system theme
  setThemeIcons(prefersDarkScheme.matches);
  
  // Listen for theme changes
  prefersDarkScheme.addEventListener('change', (event) => {
    setThemeIcons(event.matches);
  });
})();
