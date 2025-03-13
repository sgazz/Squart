# Squart

Squart je logička igra za dva igrača inspirisana igrom TicTacToe, ali sa izmenjenim pravilima.

## O igri

U igri Squart, dva igrača naizmenično postavljaju žetone na tablu. Plavi igrač postavlja horizontalne žetone (dva polja širine), a crveni igrač postavlja vertikalne žetone (dva polja visine). Cilj igre je prisiliti protivnika da ostane bez validnih poteza. Pobednik je igrač koji je odigrao poslednji validni potez.

## Funkcionalnosti

- Tabla različitih veličina (5x5 do 30x30, podrazumevano 7x7)
- "Crna" polja koja se ne mogu koristiti
- Horizontalni (plavi) i vertikalni (crveni) žetoni
- Šahovski tajmer (1 do 10 minuta po igraču)
- Različite teme (Okean, Zalazak sunca, Šuma, Galaksija, Klasična)
- Čuvanje i učitavanje partija
- Zvučni efekti
- Vibracija (haptički odziv)
- Animacije za postavljanje žetona
- Efekat konfeta za pobednika

## Kako igrati

- Plavi igrač igra prvi i postavlja žeton horizontalno (polje na koje klikne i polje desno od njega)
- Crveni igrač postavlja žeton vertikalno (polje na koje klikne i polje ispod njega)
- Igra se završava kada igrač na potezu nema validni potez ili kada mu istekne vreme
- Pobednik je igrač koji je odigrao poslednji validni potez

## Tehnički detalji

### Arhitektura

- **SwiftUI** za korisnički interfejs
- **MVVM** arhitektonski obrazac
- **Combine** za reaktivno programiranje
- **CoreData** za lokalno skladištenje
- **AVFoundation** za zvučne efekte
- **CoreHaptics** za haptički odziv

### AI implementacija

- Tri nivoa težine (lak, srednji, težak)
- Minimax algoritam sa alfa-beta odsecanjem
- Dinamička dubina pretrage bazirana na veličini table
- Keširanje pozicija za optimizaciju
- Evaluaaciona funkcija sa više parametara
- Vremensko ograničenje za poteze

### Performanse

- Optimizovano za iOS 17+
- Podrška za sve iPhone i iPad uređaje
- Efikasno korišćenje memorije
- Asinhrono učitavanje resursa
- Optimizovane animacije

### Lokalizacija

- Podržani jezici:
  - Srpski (ћирилица)
  - Engleski
  - Kineski (pojednostavljeni)
- Podrška za RTL jezike
- Lokalizovani resursi

### Testiranje

- Unit testovi za logiku igre
- UI testovi za interakciju
- Testovi performansi
- Integracioni testovi
- Testovi pristupačnosti

## Razvoj

### Pre-uslovi

- Xcode 15.0+
- iOS 17.0+
- Swift 5.9+
- Git

### Instalacija

1. Klonirajte repozitorijum
```bash
git clone https://github.com/yourusername/squart.git
```

2. Otvorite projekat
```bash
cd squart
open Squart.xcodeproj
```

3. Izgradite i pokrenite
```bash
xcodebuild -scheme Squart -destination 'platform=iOS Simulator,name=iPhone 15 Pro'
```

### API dokumentacija

Pogledajte [API.md](API.md) za detaljnu dokumentaciju.

## Doprinos

Molimo pogledajte [CONTRIBUTING.md](CONTRIBUTING.md) za detalje o procesu za podnošenje pull request-ova.

## Bezbednost

Za bezbednosne smernice, pogledajte [SECURITY.md](SECURITY.md).

## Kodni kod

Ovaj projekat prati Contributor Covenant kodni kod. Pogledajte [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md) za detalje.

## Licenca

Ovaj projekat je licenciran pod MIT licencom - pogledajte [LICENSE](LICENSE) fajl za detalje.

## Kontakt

- Email: contact@squart.app
- Twitter: [@SquartGame](https://twitter.com/SquartGame)
- Website: [https://squart.app](https://squart.app) 