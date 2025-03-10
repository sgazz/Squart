# Squart - Mašinsko učenje (ML)

Ova komponenta aplikacije Squart omogućava podršku za mašinsko učenje (ML) kako bi se unapredila veštačka inteligencija u igri. ML sistem ima sledeće mogućnosti:

1. Prikupljanje podataka iz odigranih partija za treniranje modela
2. Evaluaciju pozicija na tabli koristeći ML model
3. Inteligentnije donošenje odluka AI igrača koji koristi ML algoritme

## Komponente

ML sistem se sastoji od nekoliko ključnih komponenti:

- **MLPositionEvaluator**: klasa koja procenjuje kvalitet pozicije na tabli
- **MLPlayer**: implementacija AI igrača koji koristi ML za određivanje poteza
- **GameDataCollector**: prikuplja podatke iz partija za treniranje modela
- **train_model.py**: Python skripta za treniranje ML modela

## Korišćenje ML funkcionalnosti

### 1. Uključivanje ML u igri

Da biste koristili ML u igri:

1. Otvorite podešavanja igre
2. Omogućite opciju "AI protiv igrača" ili "AI protiv AI"
3. Uključite opciju "Koristi mašinsko učenje"
4. Izaberite težinu AI igrača
5. Započnite novu igru

### 2. Prikupljanje podataka za treniranje

ML sistem automatski prikuplja podatke tokom igranja, koji se mogu koristiti za unapređivanje modela:

1. Igrajte partije protiv AI ili pustite da AI igra protiv sebe
2. Podaci o potezima, stanjima table i pobedniku se automatski čuvaju
3. Nakon 5 odigranih partija, mock model će se automatski "trenirati" na prikupljenim podacima

### 3. Vizualizacija ML informacija

Tokom igre možete videti informacije o ML sistemu:
- Status prikupljanja podataka
- Broj snimljenih partija
- Informacije o modelu koji se koristi

## Treniranje ML modela

### Izvoz podataka

Da biste izvezli prikupljene podatke za treniranje:

```swift
let dataURL = GameDataCollector.shared.exportTrainingData()
```

### Treniranje modela koristeći Python skriptu

1. Instalirajte potrebne Python biblioteke:

```bash
pip install numpy pandas scikit-learn coremltools
```

2. Pokrenite skriptu za treniranje:

```bash
python train_model.py --input /putanja/do/squart_training_data.json --output /putanja/do/SquartMLModel.mlmodel --verbose
```

3. Dobijeni CoreML model (`SquartMLModel.mlmodel`) dodajte u Xcode projekat

### Parametri Python skripte

- `--input`: JSON fajl sa trening podacima
- `--output`: Putanja gde će se sačuvati CoreML model
- `--verbose`: Opcioni parameter za detaljnije informacije tokom treninga

## Struktura podataka za treniranje

Podaci za treniranje se izvoze u JSON formatu sa sledećom strukturom:

```json
[
  {
    "moves": [{"row": 3, "column": 4}, ...],
    "winner": "blue",
    "boardSize": 9,
    "boardStates": [...],
    "currentPlayers": ["blue", "red", ...]
  },
  ...
]
```

## Trenutna implementacija

Trenutna implementacija koristi mock model za evaluaciju pozicija. U budućim verzijama će biti implementirana puna podrška za CoreML model.

## Fallback sistem

Ako ML model nije dostupan, sistem će automatski koristiti tradicionalnu heurističku evaluaciju pozicije.

## Poboljšanje AI razmatranjem više faktora

ML sistem razmatra sledeće faktore pri evaluaciji pozicije:

1. Broj validnih poteza za igrača i protivnika
2. Kontrola ivica table
3. Kontrola ćoškova (posebno važno)
4. Kontrola centralnog dela table
5. Blokiranje protivničkih poteza
6. Mobilnost (sloboda za buduće poteze)
7. Kontrola teritorije 