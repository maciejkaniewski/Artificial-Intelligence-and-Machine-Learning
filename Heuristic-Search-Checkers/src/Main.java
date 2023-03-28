package checkers; // This package is required - don't remove it
public class EvaluatePosition // This class is required - don't remove it
{
    static private final int WIN=Integer.MAX_VALUE/2;
    static private final int LOSE=Integer.MIN_VALUE/2;
    static private boolean _color; // This field is required - don't remove it

    // Define point values for pieces
    private static final int PAWN_VALUE = 1;
    private static final int KING_VALUE = 5;

    private static final int SAFE_PAWN_VALUE = 2;
    private static final int SAFE_KING_VALUE = 3;

    private static final int MOVABLE_PAWN_VALUE = 3;
    private static final int MOVABLE_KING_VALUE = 4;

    private static final int CENTER_VALUE = 5;

    private static final int OCCUPIED_FIELD_ON_PROMOTION_LINE = 2;

    private static final int DEFENDER_PIECE = 3;

    static private int pawnOrKing(AIBoard board, int row, int column)
    {
        return (board._board[row][column].king) ? KING_VALUE : PAWN_VALUE;
    }

    static private int safePawnOrKing(AIBoard board, int row, int column)
    {
        int size=board.getSize();

        if(row == 0 || row == size - 1 || column == size -1 || column == 7)
        {
            return (board._board[row][column].king) ? SAFE_KING_VALUE : SAFE_PAWN_VALUE;
        }
        return 0;
    }

    static private int movablePawnOrKingWithoutCapturing(AIBoard board, int row, int column)
    {
        int direction = (board._board[row][column].white==getColor()) ? 1 : -1;

        if(board._board[row+direction][column-1].empty && board._board[row+direction][column+1].empty)
        {
            return (board._board[row][column].king) ? MOVABLE_KING_VALUE: MOVABLE_PAWN_VALUE;
        }
        return 0;
    }

    static private int pieceInCenter(int row, int columns)
    {
        return ((row == 3 || row == 4) && (columns == 3 || columns == 4)) ? CENTER_VALUE : 0;
    }

    static private int distanceToPromotion(AIBoard board, int row, int column)
    {
        int size=board.getSize();

        if(board._board[row][column].white==getColor())
        {
            return (board._board[row][column].king) ? 0 : row/2;
        }
        else
        {
            return (board._board[row][column].king) ? 0 : (size - 1 - row)/2;
        }
    }

    static private int occupiedFieldOnPromotionLine(AIBoard board, int row, int column)
    {
        if(board._board[row][column].white==getColor())
        {
            if(row == 0) return OCCUPIED_FIELD_ON_PROMOTION_LINE;
        }
        else
        {
            if(row == 7) return OCCUPIED_FIELD_ON_PROMOTION_LINE;
        }
        return 0;
    }

    static private int defenderPiece(AIBoard board, int row, int column)
    {
        if(board._board[row][column].white==getColor())
        {
            if(row == 0 || row == 1) return DEFENDER_PIECE;
        }
        else
        {
            if(row == 6 || row == 7) return DEFENDER_PIECE;
        }
        return 0;
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
                        myRating += safePawnOrKing(board,i,j);
                        myRating += movablePawnOrKingWithoutCapturing(board,i,j);
                        myRating += pieceInCenter(i,j);
                        myRating += distanceToPromotion(board,i,j);
                        myRating += occupiedFieldOnPromotionLine(board,i,j);
                        myRating += defenderPiece(board,i,j);
                    }
                    else
                    {
                        opponentsRating += pawnOrKing(board, i ,j);
                        opponentsRating += safePawnOrKing(board,i,j);
                        opponentsRating += movablePawnOrKingWithoutCapturing(board,i,j);
                        opponentsRating += pieceInCenter(i,j);
                        opponentsRating += distanceToPromotion(board,i,j);
                        opponentsRating += occupiedFieldOnPromotionLine(board,i,j);
                        opponentsRating += defenderPiece(board,i,j);
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