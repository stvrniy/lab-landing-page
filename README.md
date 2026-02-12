# Landing Page - Bachelor's Thesis Website

Modern responsive landing page for presenting bachelor's thesis work.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Frontend Layer                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐ │
│  │   HTML5     │  │   CSS3      │  │   Vanilla JS     │ │
│  │  (Semantic) │  │ (Variables) │  │  (Interactive)   │ │
│  └─────────────┘  └─────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Static Assets                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────┐ │
│  │   SVG       │  │  Fonts      │  │  Images         │ │
│  │  Icons      │  │  (Inter)    │  │  (Optimized)    │ │
│  └─────────────┘  └─────────────┘  └─────────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Hosting Layer                            │
│  ┌─────────────────────────────────────────────────────┐  │
│  │           GitHub Pages / Nginx / Apache             │  │
│  │         (Static File Server)                       │  │
│  └─────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Components

| Component | Description | Status |
|-----------|-------------|--------|
| Web Server | Static file serving | ✅ Required |
| Application Server | Not needed (static site) | ❌ N/A |
| Database | Not needed (static site) | ❌ N/A |
| File Storage | GitHub Pages / CDN | ✅ Required |
| Caching | Browser caching | ✅ Required |
| SSL/TLS | HTTPS | ✅ Required |

## Technology Stack

- **HTML5** - Semantic markup
- **CSS3** - Custom properties, Flexbox, Grid
- **JavaScript** - Vanilla ES6+
- **SVG** - Optimized vector graphics
- **Git** - Version control
- **GitHub Pages** - Hosting

## Quick Start

### Clone Repository

```bash
git clone https://github.com/stvrniy/lab-landing-page.git
cd lab-landing-page
```

### Install Dependencies

No dependencies required for static website!

### Development Server

#### Option 1: VS Code Live Server
1. Open project in VS Code
2. Install "Live Server" extension
3. Right-click `index.html` → "Open with Live Server"

#### Option 2: Python HTTP Server

```bash
# Python 3
python -m http.server 8000

# Python 2
python -m SimpleHTTPServer 8000
```

#### Option 3: Node.js (http-server)

```bash
npx http-server -p 8000
```

#### Option 4: PHP

```bash
php -S localhost:8000
```

Open http://localhost:8000 in your browser.

### Build & Preview

Open any HTML file directly in browser or use local server above.

## Project Structure

```
lab-landing-page/
├── index.html              # Main page (Ukrainian)
├── en/index.html          # English version
├── css/
│   ├── normalize.css      # CSS reset
│   └── styles.css         # Main styles (1000+ lines)
├── js/
│   └── main.js            # Interactive elements
├── images/
│   ├── logo.svg
│   ├── hero-illustration.svg
│   ├── tech/             # Technology icons
│   └── favicon/          # Favicon files
├── docs/                  # DevOps documentation
│   ├── deployment.md
│   ├── update.md
│   └── backup.md
├── robots.txt
├── sitemap.xml
├── README.md
└── .gitignore
```

## Development

### Coding Standards

- Semantic HTML5
- BEM naming convention for CSS
- ES6+ JavaScript
- SVG for all graphics

### Git Workflow

1. Create feature branch: `git checkout -b feature/new-section`
2. Make changes
3. Commit: `git commit -m "feat: Add new section"`
4. Push: `git push origin feature/new-section`
5. Create Pull Request

### Available Commands

```bash
# Check links (if using validation tools)
npx html-validate index.html

# Minify CSS (optional)
npx cleancss -o css/styles.min.css css/styles.css
```

## Deployment

See [docs/deployment.md](docs/deployment.md) for production deployment instructions.

## CI/CD

The project uses GitHub Actions for automatic deployment to GitHub Pages.

## License

Educational use - Bachelor's Thesis.
