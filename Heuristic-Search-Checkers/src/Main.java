package checkers; // This package is required - don't remove it

public class EvaluatePosition // This class is required - don't remove it
{
    static private final int WIN = Integer.MAX_VALUE / 2;
    static private final int LOSE = Integer.MIN_VALUE / 2;

    static private boolean _color; // This field is required - don't remove it

    static public void changeColor(boolean color) // This method is required - don't remove it
    {
        _color = color;
    }

    static public boolean getColor() // This method is required - don't remove it
    {
        return _color;
    }

    // pawnOrKing
    private static final int PAWN_VALUE = 15;
    private static final int KING_VALUE = 50;

    // movablePawnOrKingWithoutCapturing
    private static final int MOVABLE_PAWN_VALUE = 12;
    private static final int MOVABLE_KING_VALUE = 52;

    // pieceInCenter
    private static final int PAWN_CENTER_VALUE = 1;
    private static final int KING_CENTER_VALUE = 2;

    // distanceToPromotion
    private static final int DISTANCE_PROMOTION_MULTIPLIER = 1;

    // occupiedFieldOnPromotionLine
    private static final int OCCUPIED_FIELD_ON_PROMOTION_LINE = 15;

    // defenderPiece
    private static final int DEFENDER_PIECE = 2;

    // attackingPawn
    private static final int ATTACKING_PAWN = 3;

    // pieceOnDiagonal
    private static final int PAWN_DIAGONAL_VALUE = 1;
    private static final int KING_DIAGONAL_VALUE = 2;

    /**
     * @brief Checks whether the piece is pawn or king.
     *
     * @param board  game board instance
     * @param row    row where the piece is located
     * @param column column where the piece is located
     * @retval KING_VALUE when the piece is king
     * @retval PAWN_VALUE when the piece is pawn
     */
    static private int pawnOrKing(AIBoard board, int row, int column) {
        return (board._board[row][column].king) ? KING_VALUE : PAWN_VALUE;
    }

    static private int movablePawnOrKingWithoutCapturing(AIBoard board, int row, int column) {
        int direction = getColor() ? 1 : -1;

        if (board._board[row + direction][column - 1].empty && board._board[row + direction][column + 1].empty) {
            return (board._board[row][column].king) ? MOVABLE_KING_VALUE : MOVABLE_PAWN_VALUE;
        }
        return 0;
    }

    /**
     * @brief Checks whether the piece is in the center of the board.
     *
     * @param board  game board instance
     * @param row    row where the piece is located
     * @param column column where the piece is located
     * @retval KING_CENTER_VALUE when the piece in the center is king
     * @retval PAWN_CENTER_VALUE when the piece is int the center is pawn
     */
    static private int pieceInCenter(AIBoard board, int row, int column) {
        boolean center = ((row == 3 || row == 4) && (column >= 2 && column <= 5));
        return center ? (board._board[row][column].king ? KING_CENTER_VALUE : PAWN_CENTER_VALUE) : 0;
    }

    /**
     * @brief Checks the distance to the promotion line.
     *
     * @param board  game board instance
     * @param row    row where the piece is located
     * @param column column where the piece is located
     * @return value for current distance from promotion line
     */
    static private int distanceToPromotion(AIBoard board, int row, int column) {
        if (getColor()) {
            return (board._board[row][column].king) ? 0 : row * DISTANCE_PROMOTION_MULTIPLIER;
        } else {
            return (board._board[row][column].king) ? 0 : (board.getSize() - 1 - row) * DISTANCE_PROMOTION_MULTIPLIER;
        }
    }

    /**
     * @brief Checks if the field on promotion line is occupied.
     *
     * @param board  game board instance
     * @param row    row where the piece is located
     * @param column column where the piece is located
     * @retval OCCUPIED_FIELD_ON_PROMOTION_LINE when field is occupied
     * @retval 0 when it is empty
     */
    static private int occupiedFieldOnPromotionLine(AIBoard board, int row, int column) {
        boolean onPromotionLine = getColor() ? row == 0 : row == 7;
        return onPromotionLine ? OCCUPIED_FIELD_ON_PROMOTION_LINE : 0;
    }

    /**
     * @brief Checks if the piece is the defender.
     *
     * @param board  game board instance
     * @param row    row where the piece is located
     * @retval DEFENDER_PIECE when piece is defender
     * @retval 0 when piece isn't defender
     */
    static private int defenderPiece(AIBoard board, int row) {
        boolean isDefender = (getColor() && (row == 0 || row == 1)) || (!getColor() && (row == 6 || row == 7));
        return isDefender ? DEFENDER_PIECE : 0;
    }

    /**
     * @brief Checks if the pawn is the attacker.
     *
     * @param board  game board instance
     * @param row    row where the piece is located
     * @param column column where the piece is located
     * @retval ATTACKING_PAWN when pawn is attacker
     * @retval 0 when pawn isn't attacker
     */
    static private int attackingPawn(AIBoard board, int row, int column) {
        if (getColor() && row >= 4 && !board._board[row][column].king) {
            return ATTACKING_PAWN;
        } else if (!getColor() && row <= 3 && !board._board[row][column].king) {
            return ATTACKING_PAWN;
        } else {
            return 0;
        }
    }

    /**
     * @brief Checks if the piece is on the main diagonal.
     *
     * @param board  game board instance
     * @param row    row where the piece is located
     * @param column column where the piece is located
     * @retval KING_DIAGONAL_VALUE when king is on the diagonal
     * @retval PAWN_DIAGONAL_VALUE when pawn is on the diagonal
     * @retval 0 when there isn't piece on the diagonal
     */
    static private int pieceOnMainDiagonal(AIBoard board, int row, int column) {
        boolean diagonal = (row + column == board.getSize() - 1);
        return diagonal ? (board._board[row][column].king ? KING_DIAGONAL_VALUE : PAWN_DIAGONAL_VALUE) : 0;
    }

    /**
     * @brief Checks whether piece can capture.
     *
     * @param board game board instance
     * @param row row where the piece is located
     * @param column column where the piece is located
     * @param rowDir row direction to check capture, +1 for white, -1 for red
     * @param colDir column direction to check capture
     * @param color color of piece performing capture
     * @retval true if piece can capture
     * @retval false if piece can't capture
     */
    static private boolean canCaptureInDirection(AIBoard board, int row, int column, int rowDir, int colDir, boolean color) {
        int targetRow = row + 2 * rowDir;
        int targetColumn = column + 2 * colDir;

        if (targetRow < 0 || targetRow >= board.getSize() || targetColumn < 0 || targetColumn >= board.getSize()) {
            return false;
        }

        boolean isCaptureFieldEmpty = board._board[row + rowDir][column + colDir].empty;
        boolean isJumpFieldOccupied = !(board._board[targetRow][targetColumn].empty);
        boolean isPieceToCaptureWhite = board._board[row + rowDir][column + colDir].white;

        return !isCaptureFieldEmpty && isPieceToCaptureWhite != color && !isJumpFieldOccupied;
    }

    /**
     * @brief Checks if the piece can perform capture in allowed directions.
     *
     * @param board  game board instance
     * @param row    row where the piece is located
     * @param column column where the piece is located
     * @retval true if piece can capture
     * @retval false if piece can't capture
     */
    static private boolean canPerformCapture(AIBoard board, int row, int column) {
        boolean color = board._board[row][column].white;

        if (board._board[row][column].king) // kings can capture in any direction
        {
            return canCaptureInDirection(board, row, column, -1, -1, color) ||
                    canCaptureInDirection(board, row, column, -1, 1, color) ||
                    canCaptureInDirection(board, row, column, 1, -1, color) ||
                    canCaptureInDirection(board, row, column, 1, 1, color);
        } else  // regular pieces can only capture forward
        {
            return canCaptureInDirection(board, row, column, getColor() ? 1 : -1, -1, color) ||
                    canCaptureInDirection(board, row, column, getColor() ? 1 : -1, 1, color);
        }
    }

    /**
     * @brief Checks if the piece is safe.
     *
     * @param board  game board instance
     * @param row    row where the piece is located
     * @param column column where the piece is located
     * @retval true if piece is safe
     * @retval false if piece is in danger
     */
    static private boolean isPieceSafe(AIBoard board, int row, int column) {

        // Check if the piece is on the edge of the board
        if (row == 0 || row == 7 || column == 0 || column == 7) {
            return true;
        }

        // Check if the piece is blocked on both sides
        if ((!board._board[row - 1][column - 1].empty && !board._board[row + 1][column + 1].empty) ||
                (!board._board[row - 1][column + 1].empty && !board._board[row + 1][column - 1].empty)) {
            return true;
        }

        int rowDir = getColor() ? 1 : -1;

        // Check if the piece can be captured
        return (board._board[row + rowDir][column + 1].white == getColor() && board._board[row + rowDir][column - 1].white == getColor()) ||
                (!board._board[row - rowDir][column + 1].empty || !board._board[row - rowDir][column - 1].empty);
    }

    static public int evaluatePosition(AIBoard board) // This method is required and it is the major heuristic method - type your code here
    {
        int myRating = 0;
        int opponentsRating = 0;
        int size = board.getSize();

        for (int i = 0; i < size; i++) {
            for (int j = (i + 1) % 2; j < size; j += 2) {
                if (!board._board[i][j].empty) // field is not empty
                {
                    if (board._board[i][j].white == getColor()) // this is my piece
                    {
                        myRating += pawnOrKing(board, i, j);
//                        myRating += movablePawnOrKingWithoutCapturing(board,i,j); // MEH
                        myRating += pieceInCenter(board, i, j); // OK
                        myRating += distanceToPromotion(board, i, j); //OK
                        myRating += occupiedFieldOnPromotionLine(board, i, j); // OK`
                        myRating += defenderPiece(board, i); //OK
                        myRating += attackingPawn(board, i, j); //OK
                        myRating += pieceOnMainDiagonal(board, i, j); //OK
                        if (isPieceSafe(board, i, j)) myRating += 5;
                        if (canPerformCapture(board, i, j)) myRating += 3;
                    } else {
                        opponentsRating += pawnOrKing(board, i, j);
//                        opponentsRating += movablePawnOrKingWithoutCapturing(board,i,j); //MEH
                        opponentsRating += pieceInCenter(board, i, j); //OK
                        opponentsRating += distanceToPromotion(board, i, j); //OK
                        opponentsRating += occupiedFieldOnPromotionLine(board, i, j); //OK
                        opponentsRating += defenderPiece(board, i); //OK
                        opponentsRating += attackingPawn(board, i, j); //OK
                        opponentsRating += pieceOnMainDiagonal(board, i, j); //OK
                        if (isPieceSafe(board, i, j)) opponentsRating += 5;
                        if (canPerformCapture(board, i, j)) opponentsRating += 3;

                    }
                }
            }
        }

        //Judge.updateLog("Type your message here, you will see it in the log window\n");
        if (myRating == 0) return LOSE;
        else if (opponentsRating == 0) return WIN;
        else return myRating - opponentsRating;
    }
}