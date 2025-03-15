from data_generator import DataGenerator
from model import SquartModel
import os

def main():
    # Креирамо директоријум за моделе ако не постоји
    if not os.path.exists('../models'):
        os.makedirs('../models')
    
    # Генеришемо податке за тренирање
    print("Генеришем податке за тренирање...")
    generator = DataGenerator(num_games=1000)
    states, outcomes = generator.generate_training_data()
    
    # Креирамо и тренирамо модел
    print("Тренирам модел...")
    model = SquartModel()
    model.train(states, outcomes)
    
    # Чувамо модел
    print("Чувам модел...")
    model.save('../models/squart_model.joblib')
    print("Готово!")

if __name__ == "__main__":
    main() 