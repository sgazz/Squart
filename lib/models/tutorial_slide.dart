import 'package:flutter/material.dart';

/// Tutorial slide data
class TutorialSlide {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool hasInteractiveExample;
  
  const TutorialSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.hasInteractiveExample = false,
  });
}

/// Tutorial slides data
class TutorialData {
  static const List<TutorialSlide> slides = [
    // Slide 1: Basic Rules
    TutorialSlide(
      title: 'Welcome to Squart!',
      description: 'Squart is a strategic board game where two players compete to limit each other\'s moves.\nThe player who can\'t make a move loses!\nOf course, you can play against AI too!\nBoards are sized from 5×5 to 20×20.',
      icon: Icons.sports_esports,
      color: Color(0xFF6366F1), // Indigo
    ),
    
    // Slide 2: Blue Player
    TutorialSlide(
      title: 'Blue Player - Horizontal',
      description: 'Blue player places horizontal tokens.\nThese tokens block vertical movement for the opponent.',
      icon: Icons.horizontal_rule,
      color: Color(0xFF3B82F6), // Blue
    ),
    
    // Slide 3: Red Player
    TutorialSlide(
      title: 'Red Player - Vertical',
      description: 'Red player places vertical tokens.\nThese tokens block horizontal movement for the opponent.',
      icon: Icons.more_vert,
      color: Color(0xFFEF4444), // Red
    ),
    
    // Slide 4: Win Conditions & Timer
    TutorialSlide(
      title: 'How to Win',
      description: 'You win when your opponent has no valid moves left!\nOptional timer adds extra challenge - run out of time and you lose!',
      icon: Icons.emoji_events,
      color: Color(0xFFFBBF24), // Gold
      hasInteractiveExample: true,
    ),
  ];
}

