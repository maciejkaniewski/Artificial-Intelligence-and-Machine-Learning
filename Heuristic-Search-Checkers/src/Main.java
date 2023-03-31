package checkers; // This package is required - don't remove it
public class EvaluatePosition // This class is required - don't remove it
{
    static private final int WIN=Integer.MAX_VALUE/2;
    static private final int LOSE=Integer.MIN_VALUE/2;
    
    static private boolean _color; // This field is required - don't remove it

    // pawnOrKing
    private static final int PAWN_VALUE = 15;
    private static final int KING_VALUE = 50; // must be greater thean promotion distance

    // safePawnOrKing
    private static final int SAFE_PAWN_VALUE = 10;
    private static final int SAFE_KING_VALUE = 45;

    // movablePawnOrKingWithoutCapturing
    private static final int MOVABLE_PAWN_VALUE = 5;
    private static final int MOVABLE_KING_VALUE = 35;

    // pieceInCenter
    private static final int PAWN_CENTER_VALUE = 15;
    private static final int KING_CENTER_VALUE = 45;

    // distanceToPromotion
    private static final int DISTANCE_PROMOTION_MULTIPLIER = 5; // Max value 30, min value 5

    // occupiedFieldOnPromotionLine
    private static final int OCCUPIED_FIELD_ON_PROMOTION_LINE = 20;

    // defenderPiece
    private static final int DEFENDER_PIECE = 15;

    // attackingPawn
    private  static final int ATTACKING_PAWN = 8;

    // pieceOnDiagonal
    private static final int PAWN_DIAGONAL_VALUE = 12;
    private static final int KING_DIAGONAL_VALUE = 40;

    static private int pawnOrKing(AIBoard board, int row, int column)
    {
        return (board._board[row][column].king) ? KING_VALUE : PAWN_VALUE;
    }

    static private int safePawnOrKing(AIBoard board, int row, int column)
    {
        int size = board.getSize();

        if(row == 0 || row == size - 1 || column == 0 || column == size -1 )
        {
            return (board._board[row][column].king) ? SAFE_KING_VALUE : SAFE_PAWN_VALUE;
        }
        return 0;
    }

    static private int movablePawnOrKingWithoutCapturing(AIBoard board, int row, int column)
    {
        int direction = getColor() ? 1 : -1;

        if(board._board[row+direction][column-1].empty && board._board[row+direction][column+1].empty)
        {
            return (board._board[row][column].king) ? MOVABLE_KING_VALUE: MOVABLE_PAWN_VALUE;
        }
        return 0;
    }

    static private int pieceInCenter(AIBoard board, int row, int column)
    {
        boolean center = ((row == 3 || row == 4) && (column >= 2 && column <= 5));
        return center ? (board._board[row][column].king ? KING_CENTER_VALUE : PAWN_CENTER_VALUE) : 0;
    }

    static private int distanceToPromotion(AIBoard board, int row, int column)
    {
        if(getColor())
        {
            return (board._board[row][column].king) ? 0 : row*DISTANCE_PROMOTION_MULTIPLIER;
        }
        else
        {
            return (board._board[row][column].king) ? 0 : (board.getSize() - 1 - row)*DISTANCE_PROMOTION_MULTIPLIER;
        }
    }

    static private int occupiedFieldOnPromotionLine(AIBoard board, int row, int column)
    {
        boolean isWhite = getColor();
        boolean onPromotionLine = isWhite ? row == 0 : row == 7;
        return onPromotionLine ? OCCUPIED_FIELD_ON_PROMOTION_LINE : 0;
    }

    static private int defenderPiece(AIBoard board, int row, int column)
    {
        boolean isWhite = getColor();
        boolean isDefender = (isWhite && (row == 0 || row == 1)) || (!isWhite && (row == 6 || row == 7));
        return isDefender ? DEFENDER_PIECE : 0;
    }

    static private int attackingPawn(AIBoard board, int row, int column)
    {
        boolean isWhite = getColor();

        if (isWhite && row >= 4 && !board._board[row][column].king)
        {
            return ATTACKING_PAWN;
        }
        else if (!isWhite && row <= 3 && !board._board[row][column].king)
        {
            return ATTACKING_PAWN;
        }
        else
        {
            return 0;
        }
    }

    static private int pieceOnMainDiagonal(AIBoard board, int row, int column)
    {
        boolean diagonal = (row+column == board.getSize()-1);
        return diagonal ? (board._board[row][column].king ? KING_DIAGONAL_VALUE : PAWN_DIAGONAL_VALUE) : 0;
    }


    static private boolean canCaptureInDirection(AIBoard board, int row, int column, int rowDir, int colDir, boolean color)
    {
        int targetRow = row + 2 * rowDir;
        int targetColumn = column + 2 * colDir;

        // target position is out of bounds
        if (targetRow < 0 || targetRow >= board.getSize() || targetColumn < 0 || targetColumn >= board.getSize())
        {
            return false;
        }

        boolean isCaptureFieldEmpty = board._board[row + rowDir][column + colDir].empty;
        boolean isJumpFieldOccupied = !(board._board[targetRow][targetColumn].empty);
        boolean isPieceToCaptureWhite = board._board[row + rowDir][column + colDir].white;

        // there's no opponent piece to capture or the jump destination is occupied
        return !isCaptureFieldEmpty && isPieceToCaptureWhite != color && !isJumpFieldOccupied;
    }

    static private boolean canPerformCapture(AIBoard board, int row, int column)
    {
        boolean isWhite = getColor();
        boolean color = board._board[row][column].white;

        if (board._board[row][column].king) // kings can capture in any direction
        {
            return canCaptureInDirection(board, row, column, -1, -1, color) ||
                    canCaptureInDirection(board, row, column, -1, 1, color) ||
                    canCaptureInDirection(board, row, column, 1, -1, color) ||
                    canCaptureInDirection(board, row, column, 1, 1, color);
        }
       else  // regular pieces can only capture forward
        {
            return canCaptureInDirection(board, row, column, isWhite ? 1 : -1, -1, color) ||
                    canCaptureInDirection(board, row, column, isWhite ? 1 : -1, 1, color);
        }
    }

    static public void changeColor(boolean color) // This method is required - don't remove it
    {
        _color=color;
    }
    static public boolean getColor() // This method is required - don't remove it
    {
        return _color;
    }
    static public int evaluatePosition(AIBoard board) // This method is required and it is the major heuristic method - type your code here
    {
        int myRating=0;
        int opponentsRating=0;
        int size=board.getSize();

        for (int i=0;i<size;i++)
        {
            for (int j=(i+1)%2;j<size;j+=2)
            {
                if (!board._board[i][j].empty) // field is not empty
                {
                    if (board._board[i][j].white==getColor()) // this is my piece
                    {
                        myRating += pawnOrKing(board,i,j);
                        myRating += safePawnOrKing(board,i,j); // OK
                        myRating += movablePawnOrKingWithoutCapturing(board,i,j); // MEH
                        myRating += pieceInCenter(board,i,j); // OK
                        myRating += distanceToPromotion(board,i,j); //OK
                        myRating += occupiedFieldOnPromotionLine(board,i,j); // OK
                        myRating += defenderPiece(board,i,j); //OK
                        myRating += attackingPawn(board,i,j); //OK
                        myRating += pieceOnMainDiagonal(board,i,j); //OK
                        if(canPerformCapture(board,i,j))
                        {
                            myRating += 30;
                        }
                    }
                    else
                    {
                        opponentsRating += pawnOrKing(board, i ,j);
                        opponentsRating += safePawnOrKing(board,i,j); //OK
                        opponentsRating += movablePawnOrKingWithoutCapturing(board,i,j); //MEH
                        opponentsRating += pieceInCenter(board,i,j); //OK
                        opponentsRating += distanceToPromotion(board,i,j); //OK
                        opponentsRating += occupiedFieldOnPromotionLine(board,i,j); //OK
                        opponentsRating += defenderPiece(board,i,j); //OK
                        opponentsRating += attackingPawn(board,i,j); //OK
                        opponentsRating += pieceOnMainDiagonal(board,i,j); //OK
                        if(canPerformCapture(board,i,j))
                        {
                            opponentsRating += 30;
                        }
                    }
                }
            }
        }

        //Judge.updateLog("Type your message here, you will see it in the log window\n");
        if (myRating==0) return LOSE;
        else if (opponentsRating==0) return WIN;
        else return myRating-opponentsRating;
    }
}