# CoreML Model za Squart

## Specifikacija modela

**Naziv**: SquartPositionEvaluator

**Verzija**: 1.0

**Format**: CoreML (.mlmodel)

**Minimalna verzija iOS**: iOS 15.0

## Ulazi

Model prima sledeće ulaze:

- **gameState**: Float32 vektor koji predstavlja stanje igre:
  - Dimenzije zavise od veličine table (n×n + 1), gde n predstavlja veličinu table
  - Vrednosti: 0 (prazno polje), -1 (blokirano polje), 1 (plavi igrač), 2 (crveni igrač)
  - Poslednja vrednost (n×n + 1) predstavlja trenutnog igrača (1 za plavog, 2 za crvenog)

## Izlazi

Model vraća sledeće izlaze:

- **positionScore**: Float32 vrednost koja predstavlja procenu pozicije
  - Opseg: [-1, 1]
  - Pozitivne vrednosti: pozicija je dobra za trenutnog igrača
  - Negativne vrednosti: pozicija je loša za trenutnog igrača
  - Vrednosti bliže 1 ili -1 ukazuju na jaču poziciju

## Arhitektura

Model koristi sledeću arhitekturu:

- Neuronska mreža sa 4 sloja:
  - Ulazni sloj: n×n + 1 neurona
  - Prvi skriveni sloj: 128 neurona, ReLU aktivacija
  - Drugi skriveni sloj: 64 neurona, ReLU aktivacija
  - Treći skriveni sloj: 32 neurona, ReLU aktivacija
  - Izlazni sloj: 1 neuron, tanh aktivacija

## Performanse

- **Veličina modela**: ~100KB
- **Vreme inference**: <5ms na iPhone 12 ili novijim modelima
- **Preciznost**: ~75% u predviđanju pobednika

## Trening

Model je treniran na podacima prikupljenim iz stvarnih igara:

- **Veličina skupa podataka**: 10,000+ stanja igara
- **Metod treniranja**: Supervised learning
- **Loss funkcija**: Mean Squared Error (MSE)
- **Optimizer**: Adam
- **Broj epoha**: 50
- **Batch size**: 32

## Integracija

Za integraciju ovog modela u Squart aplikaciju, potrebno je:

1. Dodati `.mlmodel` fajl u Xcode projekat
2. Uveriti se da je označena opcija "Target Membership" za Squart
3. U `MLPositionEvaluator.swift`, ažurirati `prepareModel()` metodu

Primer koda za korišćenje modela:

```swift
do {
    let model = try SquartPositionEvaluator()
    let input = try MLMultiArray(shape: [boardSize * boardSize + 1], dataType: .float32)
    
    // Popuni input sa stanjem igre
    for row in 0..<boardSize {
        for col in 0..<boardSize {
            let index = row * boardSize + col
            let cellType = board[row][col]
            input[index] = cellType.toMLValue() as NSNumber
        }
    }
    
    // Dodaj trenutnog igrača
    input[boardSize * boardSize] = (currentPlayer == .blue ? 1.0 : 2.0) as NSNumber
    
    // Napravi predikciju
    let prediction = try model.prediction(gameState: input)
    return Int(prediction.positionScore * 1000)
} catch {
    print("ML greška: \(error)")
    return fallbackScore
}
```

## Napomene

- Trenutni model je u ranoj fazi razvoja
- Performanse će se poboljšati s više podataka za trening
- U planu je dodavanje podrške za različite veličine table 