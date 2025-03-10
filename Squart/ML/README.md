# Mašinsko učenje u Squart igri

Ovaj direktorijum sadrži komponente za implementaciju mašinskog učenja (ML) u Squart igru. ML je korišćen za poboljšanje AI igrača, omogućavajući mu da uči iz iskustva i donosi bolje odluke.

## Struktura

- `MLPositionEvaluator.swift` - Klasa odgovorna za evaluaciju pozicije koristeći ML model
- `GameDataCollector.swift` - Klasa za prikupljanje podataka iz igre za treniranje modela
- `MLPlayer.swift` - Implementacija AI igrača koja koristi ML za donošenje odluka
- `MLModelTraining.py` - Python skripta za treniranje ML modela (izvršava se van aplikacije)

## Kako radi

1. **Prikupljanje podataka**: Tokom igranja, `GameDataCollector` beleži sve poteze i njihov konačni ishod.
2. **Izvoz podataka**: Korisnik može izvesti prikupljene podatke za treniranje modela.
3. **Treniranje**: Python skripta `MLModelTraining.py` koristi podatke za treniranje neuronske mreže.
4. **Konverzija**: Trenirani model se konvertuje u CoreML format.
5. **Implementacija**: Model se učitava u aplikaciju i koristi za procenu pozicije.

## Hibridni pristup

Squart koristi hibridni pristup za AI:

- **Minimax algoritam** se koristi za pretragu poteza unapred.
- **Neuronska mreža** se koristi za brzu procenu pozicije, što omogućava efikasnije pretrage.
- **Heuristike** se koriste kao rezervna strategija kada ML model nije dostupan.

## Treniranje modela

### Preduslovi

- Python 3.6+
- TensorFlow 2.0+
- CoreMLTools
- NumPy

### Koraci za treniranje

1. Izvezite podatke iz aplikacije (podešavanja → ML → "Izvezi podatke za treniranje").
2. Instalirajte potrebne Python biblioteke:
   ```
   pip install tensorflow numpy coremltools
   ```
3. Pokrenite skriptu za treniranje:
   ```
   python MLModelTraining.py --data path/to/squart_training_data.json --output SquartModel.mlmodel --epochs 50
   ```
4. Dodajte trenirani model u Xcode projekat.

## Implementacija modela

Nakon što imate trenirani CoreML model, dodajte ga u Xcode projekat:

1. Prevucite `.mlmodel` fajl u Xcode projekat.
2. Uverite se da je označena opcija "Target Membership" za Squart.
3. U `MLPositionEvaluator.swift`, ažurirajte `prepareModel()` metodu da učita vaš model.

## Performanse i optimizacija

- ML model je optimizovan za brzu evaluaciju pozicije.
- Za veliki broj poteza, ML se koristi za preliminarnu procenu kako bi se identifikovali najobećavajući potezi.
- Detaljnija pretraga se zatim primenjuje samo na te poteze.

## Dalji razvoj

Moguća poboljšanja uključuju:

- Konvolucione neuronske mreže (CNN) za bolje prepoznavanje prostornih šablona na tabli.
- Reinforcement Learning (RL) gde AI uči kroz igranje protiv sebe.
- Self-play strategiju za generisanje većih količina podataka za trening. 