package checkers; // This package is required - don't remove it
public class EvaluatePosition // This class is required - don't remove it
{
    static private final int WIN=Integer.MAX_VALUE/2;
    static private final int LOSE=Integer.MIN_VALUE/2;
    static private boolean _color; // This field is required - don't remove it

    // Define point values for pieces
    private static final int REGULAR_PIECE_VALUE = 1;
    private static final int KING_VALUE = 5;
    private static final int CENTER_VALUE = 1;

    static private int pieceOrKing(AIBoard board, int row, int column)
    {
        return (board._board[row][column].king) ? KING_VALUE : REGULAR_PIECE_VALUE;
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
            return (board._board[row][column].king) ? 0 : size - 1 - row;
        }
        else
        {
            return (board._board[row][column].king) ? 0 : row;
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
                        myRating += pieceOrKing(board,i,j);
                        myRating += pieceInCenter(i,j);
                        myRating +=  distanceToPromotion(board,i,j);
                    }
                    else
                    {
                        opponentsRating += pieceOrKing(board, i ,j);
                        opponentsRating += pieceInCenter(i,j);
                        opponentsRating += distanceToPromotion(board,i,j);
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