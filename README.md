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

- Razvijeno u SwiftUI
- Kompatibilno sa iOS 17+
- Prilagodljiv UI za različite veličine ekrana i orijentacije 