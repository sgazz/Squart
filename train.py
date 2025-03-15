from data_generator import DataGenerator
from model import SquartModel
import os

def main():
    print("Почињем тренирање...")
    
    if not os.path.exists("../models"):
        print("Креирам директоријум за моделе...")
        os.makedirs("../models")
    
    print("Генеришем податке за тренирање...")
    generator = DataGenerator(num_games=1000)
    states, outcomes = generator.generate_training_data()
    print(f"Генерисано {len(states)} примера за тренирање")
    
    print("Тренирам модел...")
    model = SquartModel()
    model.train(states, outcomes)
    
    print("Чувам модел...")
    model_path = "../models/squart_model.joblib"
    model.save(model_path)
    print(f"Модел сачуван у: {model_path}")
    print("Готово!")

if __name__ == "__main__":
    main() 