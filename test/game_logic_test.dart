import 'package:flutter_test/flutter_test.dart';
import 'package:squart/services/game_logic_service.dart';
import 'package:squart/models/game_settings.dart';
import 'package:squart/core/constants/game_constants.dart';

void main() {
  late GameLogicService gameLogic;

  setUp(() {
    gameLogic = GameLogicService();
  });

  group('Board Generation', () {
    test('Creates board with correct size', () {
      final settings = GameSettings(boardSize: 7);
      final gameState = gameLogic.createNewGame(settings);

      expect(gameState.board.length, 7);
      expect(gameState.board[0].length, 7);
    });

    test('Black cells percentage is within range', () {
      final settings = GameSettings(boardSize: 10);
      final gameState = gameLogic.createNewGame(settings);

      final percentage = gameLogic.getBlackCellsPercentage(gameState.board);
      
      expect(percentage, greaterThanOrEqualTo(GameConstants.minBlackCellsPercent));
      expect(percentage, lessThanOrEqualTo(GameConstants.maxBlackCellsPercent));
    });

    test('All board positions are initialized', () {
      final settings = GameSettings(boardSize: 5);
      final gameState = gameLogic.createNewGame(settings);

      for (int row = 0; row < 5; row++) {
        for (int col = 0; col < 5; col++) {
          expect(gameState.board[row][col].row, row);
          expect(gameState.board[row][col].col, col);
        }
      }
    });
  });

  group('Move Validation', () {
    test('Valid horizontal move for blue player', () {
      final settings = GameSettings(boardSize: 5);
      var gameState = gameLogic.createNewGame(settings);
      
      // Find first available horizontal position
      for (int row = 0; row < 5; row++) {
        for (int col = 0; col < 4; col++) {
          if (gameLogic.isValidMove(gameState, row, col)) {
            expect(gameState.isBluesTurn, true);
            return;
          }
        }
      }
    });

    test('Invalid move outside board bounds', () {
      final settings = GameSettings(boardSize: 5);
      final gameState = gameLogic.createNewGame(settings);

      expect(gameLogic.isValidMove(gameState, -1, 0), false);
      expect(gameLogic.isValidMove(gameState, 0, -1), false);
      expect(gameLogic.isValidMove(gameState, 5, 0), false);
      expect(gameLogic.isValidMove(gameState, 0, 5), false);
    });

    test('Cannot place token on edge for horizontal (blue)', () {
      final settings = GameSettings(boardSize: 5);
      final gameState = gameLogic.createNewGame(settings);

      // Last column would go out of bounds
      final isValid = gameLogic.isValidMove(gameState, 0, 4);
      expect(isValid, false);
    });
  });

  group('Token Placement', () {
    test('Places token and switches player', () {
      final settings = GameSettings(boardSize: 7);
      var gameState = gameLogic.createNewGame(settings);

      expect(gameState.currentPlayer, GameConstants.playerBlue);
      expect(gameState.tokens.length, 0);

      // Find valid move
      final validMoves = gameLogic.getValidMoves(gameState);
      expect(validMoves, isNotEmpty);

      final (row, col) = validMoves.first;
      gameState = gameLogic.placeToken(gameState, row, col);

      expect(gameState.tokens.length, 1);
      expect(gameState.currentPlayer, GameConstants.playerRed);
      expect(gameState.board[row][col].occupiedBy, GameConstants.playerBlue);
    });

    test('Token occupies two cells correctly', () {
      final settings = GameSettings(boardSize: 7);
      var gameState = gameLogic.createNewGame(settings);

      // Find valid horizontal move for blue
      final validMoves = gameLogic.getValidMoves(gameState);
      final (row, col) = validMoves.first;

      gameState = gameLogic.placeToken(gameState, row, col);

      // Check both cells are occupied
      expect(gameState.board[row][col].occupiedBy, GameConstants.playerBlue);
      expect(gameState.board[row][col + 1].occupiedBy, GameConstants.playerBlue);
    });
  });

  group('Win Conditions', () {
    test('Game ends when no valid moves remain', () {
      // Create a small board for easier testing (minimum is 5)
      final settings = GameSettings(boardSize: 5);
      var gameState = gameLogic.createNewGame(settings);

      // Keep playing until game ends or max moves
      int maxMoves = 20;
      int moves = 0;

      while (!gameState.isFinished && moves < maxMoves) {
        final validMoves = gameLogic.getValidMoves(gameState);
        if (validMoves.isEmpty) break;

        final (row, col) = validMoves.first;
        gameState = gameLogic.placeToken(gameState, row, col);
        moves++;
      }

      // Either game finished or board is full
      if (gameState.isFinished) {
        expect(gameState.winner, isNotNull);
        expect(gameState.winReason, GameConstants.winNoMoves);
      }
    });
  });

  group('Timer Functionality', () {
    test('Timer updates correctly', () {
      final settings = GameSettings(
        boardSize: 5,
        timePerPlayer: 60,
      );
      var gameState = gameLogic.createNewGame(settings);

      expect(gameState.blueTimeRemaining, 60);
      expect(gameState.redTimeRemaining, 60);

      // Update timer (blue's turn)
      gameState = gameLogic.updateTimer(gameState);
      expect(gameState.blueTimeRemaining, 59);
      expect(gameState.redTimeRemaining, 60);
    });

    test('Game ends on timeout', () {
      final settings = GameSettings(
        boardSize: 5,
        timePerPlayer: 1,
      );
      var gameState = gameLogic.createNewGame(settings);

      // Reduce blue's time to 0
      gameState = gameState.copyWith(blueTimeRemaining: 0);
      gameState = gameLogic.checkTimeout(gameState);

      expect(gameState.isFinished, true);
      expect(gameState.winner, GameConstants.playerRed);
      expect(gameState.winReason, GameConstants.winTimeout);
    });

    test('Unlimited timer does not update', () {
      final settings = GameSettings(
        boardSize: 5,
        timePerPlayer: GameConstants.timerUnlimited,
      );
      var gameState = gameLogic.createNewGame(settings);

      final initialBlueTime = gameState.blueTimeRemaining;
      gameState = gameLogic.updateTimer(gameState);

      expect(gameState.blueTimeRemaining, initialBlueTime);
    });
  });

  group('Pause and Resume', () {
    test('Pause game changes status', () {
      final settings = GameSettings(boardSize: 5);
      var gameState = gameLogic.createNewGame(settings);

      expect(gameState.isPlaying, true);

      gameState = gameLogic.pauseGame(gameState);
      expect(gameState.isPaused, true);
    });

    test('Resume game changes status back', () {
      final settings = GameSettings(boardSize: 5);
      var gameState = gameLogic.createNewGame(settings);

      gameState = gameLogic.pauseGame(gameState);
      expect(gameState.isPaused, true);

      gameState = gameLogic.resumeGame(gameState);
      expect(gameState.isPlaying, true);
    });
  });
}

