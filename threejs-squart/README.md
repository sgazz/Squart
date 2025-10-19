# 🎮 Squart - 3D Strategic Board Game

**Squart** je strategijska logička igra za dva igrača u 3D prostoru, implementirana sa **Three.js**. Igra je inspirisana igrom Domineering, ali sa izmenjenim pravilima za bolju strategijsku dubinu.

## 🚀 Demo

[**🎥 Live Demo**](https://your-demo-url.com) - Igraj odmah u browseru!

## 📖 O igri

U igri Squart, dva igrača naizmenično postavljaju žetone na 3D tablu:
- **Plavi igrač** postavlja horizontalne žetone (dva polja širine)
- **Crveni igrač** postavlja vertikalne žetone (dva polja visine)
- **Crna polja** se ne mogu koristiti (17-19% od ukupnih polja)
- Cilj: Prisiliti protivnika da ostane bez validnih poteza
- Pobednik je igrač koji je odigrao poslednji validni potez

## ✨ Funkcionalnosti

### 🎯 Gameplay
- ✅ **3D tabla** različitih veličina (od 5×5 do 20×20, podrazumevano 7×7)
- ✅ **Crna polja** koja se ne mogu koristiti (17-19% od ukupnih polja)
- ✅ **Player vs Player** - igraj sa prijateljem
- ✅ **Player vs AI** - igraj protiv računara sa 4 nivoa težine:
  - Easy - Slučajni potezi
  - Medium - Osnovne strategije
  - Hard - Napredniji AI
  - Expert - Minimax algoritam sa alpha-beta pruning
- ✅ **Šahovski tajmer** (1-10 minuta po igraču ili neograničeno)

### 🎨 3D Vizuelni efekti
- ✅ **Isometric perspektiva** - tabla kao 3D platforma
- ✅ **Floating žetoni** - žetoni lebde iznad table
- ✅ **Smooth animacije** - GSAP animacije za postavljanje žetona
- ✅ **Dynamic lighting** - svetlo se menja sa temom
- ✅ **Glassmorphism UI** - moderni dizajn sa blur efektima
- ✅ **Dark & Light teme** sa lepim gradijent pozadinama

### 🔧 Tehničke karakteristike
- ✅ **Three.js** - 3D rendering engine
- ✅ **WebGL** - hardware accelerated graphics
- ✅ **PWA podrška** - offline igranje
- ✅ **Responsive dizajn** - radi na svim uređajima
- ✅ **Touch podrška** - optimizovano za mobilne uređaje
- ✅ **Keyboard shortcuts** - brže navigiranje
- ✅ **Local Storage** - čuvanje postavki i igre

### 🎵 Audio & Feedback
- ✅ **Web Audio API** - high-quality sound effects
- ✅ **Zvučni efekti** - token place, win, lose, tick, invalid
- ✅ **Haptički feedback** (vibracija na mobilnim uređajima)
- ✅ **Audio context management** - automatska aktivacija

## 🎮 Kako igrati

### 🎯 Osnovna Pravila

- **Plavi igrač** postavlja žeton **horizontalno** (polje na koje klikne i polje desno od njega)
- **Crveni igrač** postavlja žeton **vertikalno** (polje na koje klikne i polje ispod njega)
- **Crna polja** se ne mogu koristiti - nasumično raspodeljena na tabli (17-19%)
- Igra se završava kada igrač na potezu nema validni potez ili kada mu istekne vreme
- **Pobednik** je igrač koji je odigrao poslednji validni potez

### 🎮 Kontrole

#### Desktop
- **LMB** - Klik na polje za postavljanje žetona
- **Wheel** - Zoom in/out
- **Drag** - Rotacija kamere oko table
- **Space** - Pauza/nastavi igru
- **H** - Prikaži/sakrij hints
- **N** - Nova igra
- **T** - Promeni temu
- **Esc** - Povratak u glavni meni

#### Mobile/Touch
- **Tap** - Klik na polje za postavljanje žetona
- **Pinch** - Zoom in/out
- **Drag** - Rotacija kamere oko table
- **Swipe gestures** - Navigacija kroz menije

## 🛠️ Tehnologije

### Core
- **Three.js** - 3D graphics library
- **WebGL** - Hardware accelerated rendering
- **JavaScript ES6+** - Modern JavaScript features
- **CSS3** - Advanced styling with glassmorphism

### Libraries
- **GSAP** - Professional animations
- **Font Awesome** - Icons
- **Web Audio API** - Sound management

### PWA Features
- **Service Worker** - Offline functionality
- **Web App Manifest** - App-like experience
- **IndexedDB** - Local data storage
- **Background Sync** - Data synchronization

## 📱 Podržane Platforme

- ✅ **Desktop** - Chrome, Firefox, Safari, Edge
- ✅ **Mobile** - iOS Safari, Android Chrome
- ✅ **Tablet** - iPad, Android tablets
- ✅ **PWA** - Instaliraj kao aplikacija

## 🚀 Pokretanje (Development)

### Prerequisites
- Modern web browser sa WebGL podrškom
- Local web server (za development)

### Lokalno pokretanje

```bash
# Clone repository
git clone https://github.com/your-username/squart-threejs.git
cd squart-threejs

# Start local server (Python)
python -m http.server 8000

# Ili Node.js
npx serve .

# Ili PHP
php -S localhost:8000
```

Zatim otvori: `http://localhost:8000`

### Production Build

```bash
# Optimize assets (opciono)
npm install -g http-server
http-server . -p 8000 -c-1
```

## 📦 Deployment

### GitHub Pages
```bash
# Push to gh-pages branch
git subtree push --prefix . origin gh-pages
```

### Vercel
```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel --prod
```

### Netlify
```bash
# Install Netlify CLI
npm i -g netlify-cli

# Deploy
netlify deploy --prod --dir .
```

## 🏗️ Struktura Projekta

```
threejs-squart/
├── index.html              # Main HTML file
├── manifest.json           # PWA manifest
├── sw.js                   # Service Worker
├── styles/
│   └── main.css           # Main stylesheet
├── src/
│   ├── main.js            # Application entry point
│   ├── utils/
│   │   ├── Constants.js   # Game constants
│   │   └── Helpers.js     # Utility functions
│   ├── game/
│   │   ├── Cell.js        # Cell model
│   │   ├── Token.js       # Token model
│   │   ├── GameLogic.js   # Game logic
│   │   └── GameBoard.js   # 3D board rendering
│   └── audio/
│       └── AudioManager.js # Audio management
└── assets/
    ├── icons/             # PWA icons
    ├── sounds/            # Audio files
    └── screenshots/       # PWA screenshots
```

## 🧪 Testing

### Browser Compatibility
- ✅ Chrome 90+
- ✅ Firefox 88+
- ✅ Safari 14+
- ✅ Edge 90+

### Performance
- ✅ 60 FPS na desktop uređajima
- ✅ 30+ FPS na mobilnim uređajima
- ✅ < 3MB total bundle size
- ✅ < 2s loading time

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Guidelines
1. Follow ES6+ standards
2. Use meaningful variable names
3. Add comments for complex logic
4. Test on multiple browsers
5. Optimize for performance

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

## 👨‍💻 Author

**Stanko Gazza**
- GitHub: [@sgazz](https://github.com/sgazz)
- Project: [Squart Three.js](https://github.com/sgazz/squart-threejs)

## 🙏 Acknowledgments

- Inspirisano igrom **Domineering** sa modifikovanim pravilima
- **Three.js** community za odličnu dokumentaciju
- **GSAP** za profesionalne animacije
- **Font Awesome** za ikone

## 🔮 Future Features

- [ ] **Multiplayer** - Real-time online igranje
- [ ] **VR Support** - Virtual Reality experience
- [ ] **Tournament Mode** - Turnirski sistem
- [ ] **AI Improvements** - Bolji AI algoritmi
- [ ] **Custom Themes** - Korisničke teme
- [ ] **Statistics** - Detaljne statistike igre
- [ ] **Replay System** - Pregled prethodnih partija

---

**Version:** 1.0.0  
**Last Updated:** December 2024  
**Status:** ✅ Production Ready

🎮 **Uživajte u igranju Squart-a!**
