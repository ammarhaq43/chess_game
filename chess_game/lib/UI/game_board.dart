import 'package:flutter/material.dart';
import 'package:chess_game/components/piece.dart';
import 'package:chess_game/components/square.dart';
import 'package:chess_game/values/colors.dart';

import '../components/dead_pieces.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late List<List<ChessPiece?>> board;
  ChessPiece? selectedPiece;
  int selectedRow = -1;
  int selectedCol = -1;
  List<List<int>> validMoves = [];

  //A list of white pieces that have been taken by the black player
  List<ChessPiece> whitePiecesTaken = [];

  //A list of black pieces that have been taken by the white player
  List<ChessPiece> blackPiecesTaken = [];

  //A boolean to indicate whose turn it is
  bool isWhiteTurn = true;

  //initial position of kings (keep track of this to make it easier later to see if king is in check)
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;
  bool simulatedMoveIsSafe = true;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  void _initializeBoard() {
    board = List.generate(8, (index) => List.generate(8, (index) => null));

    // Initialize pawns
    for (int i = 0; i < 8; i++) {
      board[1][i] = ChessPiece(type: ChessPiecesType.pawn, isWhite: false, imagePath: 'assets/pawn.png');
      board[6][i] = ChessPiece(type: ChessPiecesType.pawn, isWhite: true, imagePath: 'assets/pawn.png');
    }

    // Initialize rooks
    board[0][0] = ChessPiece(type: ChessPiecesType.rook, isWhite: false, imagePath: 'assets/rook.png');
    board[0][7] = ChessPiece(type: ChessPiecesType.rook, isWhite: false, imagePath: 'assets/rook.png');
    board[7][0] = ChessPiece(type: ChessPiecesType.rook, isWhite: true, imagePath: 'assets/rook.png');
    board[7][7] = ChessPiece(type: ChessPiecesType.rook, isWhite: true, imagePath: 'assets/rook.png');

    // Initialize knights
    board[0][1] = ChessPiece(type: ChessPiecesType.knight, isWhite: false, imagePath: 'assets/knight.png');
    board[0][6] = ChessPiece(type: ChessPiecesType.knight, isWhite: false, imagePath: 'assets/knight.png');
    board[7][1] = ChessPiece(type: ChessPiecesType.knight, isWhite: true, imagePath: 'assets/knight.png');
    board[7][6] = ChessPiece(type: ChessPiecesType.knight, isWhite: true, imagePath: 'assets/knight.png');

    // Initialize bishops
    board[0][2] = ChessPiece(type: ChessPiecesType.bishop, isWhite: false, imagePath: 'assets/bishop.png');
    board[0][5] = ChessPiece(type: ChessPiecesType.bishop, isWhite: false, imagePath: 'assets/bishop.png');
    board[7][2] = ChessPiece(type: ChessPiecesType.bishop, isWhite: true, imagePath: 'assets/bishop.png');
    board[7][5] = ChessPiece(type: ChessPiecesType.bishop, isWhite: true, imagePath: 'assets/bishop.png');

    // Initialize queens
    board[0][3] = ChessPiece(type: ChessPiecesType.queen, isWhite: false, imagePath: 'assets/queen.png');
    board[7][4] = ChessPiece(type: ChessPiecesType.queen, isWhite: true, imagePath: 'assets/queen.png');

    // Initialize kings
    board[0][4] = ChessPiece(type: ChessPiecesType.king, isWhite: false, imagePath: 'assets/king.png');
    board[7][3] = ChessPiece(type: ChessPiecesType.king, isWhite: true, imagePath: 'assets/king.png');

  }

  void pieceSelected(int row, int col) {
    setState(() {
      //No piece has been selected yet, this is the first selection
      if(selectedPiece == null && board[row] [col] != null){
        if(board [row][col] !.isWhite == isWhiteTurn){
          selectedPiece = board [row] [col];
          selectedRow = row;
          selectedCol = col;
        }
      }
      //There is a piece selected and user taps on a square that is a valid move, move there
      else if(board[row] [col] != null && board[row][col] !.isWhite == selectedPiece!.isWhite){
        selectedPiece = board [row] [col];
        selectedRow = row;
        selectedCol = col;
      }
      //if there is a piece selected and user taps on a square that is a valid move, move there
      else if(selectedPiece != null && validMoves.any((element) => element[0] == row && element[1] == col)){
        moveSelectedPiece(row, col);
      }

      validMoves = calculateRawValidMoves(selectedRow, selectedCol, selectedPiece);

    });
  }

  List<List<int>> calculateRawValidMoves(int row, int col, ChessPiece? piece) {
    List<List<int>> candidateMoves = [];

    List<List<int>> calculateRealValidMoves(int row, int col, ChessPiece? piece, bool checkSimulation) {
      List<List<int>> realValidMoves = [];
      List<List<int>> candidateMoves = calculateRawValidMoves(row, col, piece);

      if (checkSimulation) {
        for (var move in candidateMoves) {
          int endRow = move[0];
          int endCol = move[1];

          // Simulate the move and check if it is safe
          if (simulatedMoveIsSafe) {
            realValidMoves.add(move);
          }
        }
      } else {
        // If no simulation is needed, use candidate moves directly
        realValidMoves = candidateMoves;
      }

      return realValidMoves;
    }


    int direction = piece!.isWhite ? -1 : 1;

    switch (piece.type) {
      case ChessPiecesType.pawn:
        if (isInBoard(row + direction, col) && board[row + direction][col] == null) {
          candidateMoves.add([row + direction, col]);
        }
        if ((row == 1 && !piece.isWhite) || (row == 6 && piece.isWhite)) {
          if (isInBoard(row + 2 * direction, col) && board[row + 2 * direction][col] == null && board[row + direction][col] == null) {
            candidateMoves.add([row + 2 * direction, col]);
          }
        }
        if (isInBoard(row + direction, col - 1) && board[row + direction][col - 1] != null && board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col - 1]);
        }
        if (isInBoard(row + direction, col + 1) && board[row + direction][col + 1] != null && board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candidateMoves.add([row + direction, col + 1]);
        }
        break;

      case ChessPiecesType.rook:
        var directions = [
          [-1, 0], // up
          [1, 0],  // down
          [0, -1], // left
          [0, 1],  // right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // capture
              }
              break; // blocked
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;

      case ChessPiecesType.knight:
        var knightMoves = [
          [-2, -1], [-2, 1],
          [-1, -2], [-1, 2],
          [1, -2], [1, 2],
          [2, -1], [2, 1],
        ];

        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); // capture
            }
            continue; // blocked
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;

      case ChessPiecesType.bishop:
        var directions = [
          [-1, -1], // up left
          [-1, 1],  // up right
          [1, -1],  // down left
          [1, 1],   // down right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // capture
              }
              break; // blocked
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;

      case ChessPiecesType.queen:
        var directions = [
          [-1, 0],  // up
          [1, 0],   // down
          [0, -1],  // left
          [0, 1],   // right
          [-1, -1], // up left
          [-1, 1],  // up right
          [1, -1],  // down left
          [1, 1],   // down right
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            }
            if (board[newRow][newCol] != null) {
              if (board[newRow][newCol]!.isWhite != piece.isWhite) {
                candidateMoves.add([newRow, newCol]); // capture
              }
              break; // blocked
            }
            candidateMoves.add([newRow, newCol]);
            i++;
          }
        }
        break;

      case ChessPiecesType.king:
        var kingMoves = [
          [-1, 0], [1, 0],
          [0, -1], [0, 1],
          [-1, -1], [-1, 1],
          [1, -1], [1, 1],
        ];

        for (var move in kingMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null) {
            if (board[newRow][newCol]!.isWhite != piece.isWhite) {
              candidateMoves.add([newRow, newCol]); // capture
            }
            continue; // blocked
          }
          candidateMoves.add([newRow, newCol]);
        }
        break;
    }

    return candidateMoves;
  }

  bool isInBoard(int row, int col) {
    return row >= 0 && row < 8 && col >= 0 && col < 8;
  }

  bool moveSelectedPiece(int newRow, int newCol) {
    setState(() {
      // Capture the piece if there is one at the new position
      if (board[newRow][newCol] != null) {
        var capturedPiece = board[newRow][newCol];
        if (capturedPiece!.isWhite) {
          whitePiecesTaken.add(capturedPiece);
        } else {
          blackPiecesTaken.add(capturedPiece);
        }
      }

      //check if the piece being moved in a king
      if(selectedPiece!.type == ChessPiecesType.king){
        //update the appropriate king pos
        if(selectedPiece!.isWhite){
          whiteKingPosition = [newRow, newCol];
        }else{
          blackKingPosition = [newRow, newCol];
        }
      }

      // Move the piece
      board[newRow][newCol] = selectedPiece;
      board[selectedRow][selectedCol] = null;

      // Check if any kings are under attack
      // Declare the function before using it
      bool isKingInCheck(bool isWhiteKing) {
        // Get the position of the king
        List<int> kingPosition = isWhiteKing ? whiteKingPosition : blackKingPosition;

        // Check if any enemy piece can attack the king
        for (int i = 0; i < 8; i++) {
          for (int j = 0; j < 8; j++) {
            // Skip empty squares and pieces of the same color as the king
            if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
              continue;
            }

            List<List<int>> pieceValidMoves = calculateRawValidMoves(i, j, board[i][j]);

            // Check if the king's position is in this piece's valid moves
            if (pieceValidMoves.any((move) => move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
              return true;
            }
          }
        }

        // If no piece can attack the king, return false
        return false;
      }

// Now you can check if any kings are under attack
      if(isKingInCheck(!isWhiteTurn)){
        checkStatus = true;
      } else {
        checkStatus = false;
      }


// Clear the selection and reset the state
      selectedPiece = null;
      selectedRow = -1;
      selectedCol = -1;
      validMoves = [];

// Change turns
      isWhiteTurn = !isWhiteTurn;
    });

// IS KING IN CHECK?
    bool isKingInCheck(bool isWhiteKing) {
      // Get the position of the king
      List<int> kingPosition = isWhiteKing ? whiteKingPosition : blackKingPosition;

      //SIMULATE A FUTURE MOVE TO SEE IF IT'S SAFE (DOESN'T PUT YOUR OWN KING UNDER ATTACK!)
      bool simulatedMoveIsSafe(ChessPiece piece, int startRow, int startCol,int endRow, int endCol){
        //save the current board state
        ChessPiece? originalDestinationPiece = board[endRow][endCol];

        //if the piece is the king, save it's current position and update to the new one
        List<int>? originalKingPosition;
        if(piece.type == ChessPiecesType.king){
          originalKingPosition = piece.isWhite ? whiteKingPosition : blackKingPosition;

          //update the king position
          if(piece.isWhite){
            whiteKingPosition = [endRow, endCol];
          }else{
            blackKingPosition = [endRow, endCol];
          }
        }
        //simulate the move
        board [endRow] [endCol] = piece;
        board[startRow][startCol] = null;

        //check if our king is under attack
        bool kingInCheck = isKingInCheck(piece.isWhite);

        //restore board to original state
        board[startRow][startCol] = piece;
        board[startRow][startCol] = originalDestinationPiece;

        //if the piece was the king, restore it original position
        if(piece.type == ChessPiecesType.king){
          if(piece.isWhite){
            whiteKingPosition = originalKingPosition!;
          }else{
            blackKingPosition = originalKingPosition!;
          }
        }
        //if king is in check = true, means it's not a safe move. safe move = false
        return !kingInCheck;
      }


      // Check if any enemy piece can attack the king
      for (int i = 0; i < 8; i++) {
        for (int j = 0; j < 8; j++) {
          // Skip empty squares and pieces of the same color as the king
          if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
            continue;
          }

          List<List<int>> pieceValidMoves = calculateRawValidMoves(i, j, board[i][j]);

          // Check if the king's position is in this piece's valid moves
          if (pieceValidMoves.any((move) => move[0] == kingPosition[0] && move[1] == kingPosition[1])) {
            return true;
          }
        }
      }

      // If no piece can attack the king, return false
      return false;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          //WHITE PIECES TAKEN
          Expanded(
            child: GridView.builder(
                itemCount: whitePiecesTaken.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                itemBuilder: (context, index) => DeadPieces(
                  imagePath: whitePiecesTaken[index].imagePath,
                  isWhite: true,
                )
            ),
          ),
          //Game Status
          Text(checkStatus ? "CHECK!" : ""),
          //CHESS BOARD
          // Adjust the flex values as needed
          Expanded(
            flex: 5,
            child: GridView.builder(
              itemCount: 8 * 8,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemBuilder: (context, index) {
                int row = index ~/ 8;
                int col = index % 8;
                bool isSelected = selectedRow == row && selectedCol == col;
                bool isValidMove = false;

                for (var pos in validMoves) {
                  if (pos[0] == row && pos[1] == col) {
                    isValidMove = true;
                  }
                }

                return Square(
                  isWhite: (row + col) % 2 == 0,
                  piece: board[row][col],
                  isSelected: isSelected,
                  isValidMove: isValidMove,
                  onTap: () {
                    if (selectedPiece == null) {
                      pieceSelected(row, col);
                    } else if (isValidMove) {
                      moveSelectedPiece(row, col);
                    }
                  },
                );
              },
            ),
          ),

          //BLACK PIECES TAKEN
          Expanded(
            child: GridView.builder(
                itemCount: blackPiecesTaken.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
                itemBuilder: (context, index) => DeadPieces(
                  imagePath: blackPiecesTaken[index].imagePath,
                  isWhite: false,
                )
            ),
          ),
        ],
      ),

    );
  }
  }
