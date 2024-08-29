import 'package:chess_game/values/colors.dart';
import 'package:flutter/material.dart';
import 'package:chess_game/components/piece.dart';

class Square extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  final bool isValidMove;
  final void Function()? onTap;

  const Square({
    super.key,
    required this.isWhite,
    required this.piece,
    required this.isSelected,
    required this.isValidMove,
    required this.onTap
  });

  Color? _getSquareColor() {
    if (isSelected) {
      return Colors.green; // Highlight selected square in green
    } else if (isValidMove) {
      return Colors.lightGreen; // Highlight valid move squares in yellow
    } else {
      return isWhite ? foregroundColor : backgroundColor; // Default square colors
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: _getSquareColor(),
        margin: EdgeInsets.all(isValidMove ? 8:0),
        child: piece != null
            ? Image.asset(
          piece!.imagePath,
          color: piece!.isWhite ? Colors.white : Colors.black,
          fit: BoxFit.contain,
        )
            : null,
      ),
    );
  }
}
