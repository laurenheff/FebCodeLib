import java.util.Scanner;
// This game is designed for play by 2 people

public class TicTacToe{

    //STAGE ONE: SET UP GAME WORKFLOW & COMPONENTS
    
    //possible states and outcomes
   public static final int GAME_IN_PROGRESS = 1;
   public static final int CATS_GAME = 0;
   public static final int EX_GAME = 2;
   public static final int OH_GAME = 3;
   
   //board creation
   public static int[][] BOARD = new int[3][3]; 
   public static final int BLANK_CELL = 0;
   public static final int EXPLAY = 1;
   public static final int OHPLAY = 2;
   
   public static int CURRENT_PLAYER; // Player EX starts every new game
   public static int CURRENT_STATUS; // This will change depending on progression of play
   public static int ROW, COLUMN; // used for input of each new move
   public static Scanner in = new Scanner(System.in); // checks status before each new move
 
   //Down to business! Here we initialize and play the game from start to finish.
   public static void main(String[] args) {
      startTicTacToe();
      do {
         playNextMove(CURRENT_PLAYER); 
         processNextMove(CURRENT_PLAYER, ROW, COLUMN); 
         printLastMove();
         
         // Status Check To Exit If Game Has Completed
         if (CURRENT_STATUS == CATS_GAME) {
             System.out.println("Oops, Looks Like The Cat Took This One! Better Luck Next Time.");
         }  else if (CURRENT_STATUS == EX_GAME) {
             System.out.println("Well Done Player 1! X Wins, Game Over.");
         }  else if (CURRENT_STATUS == OH_GAME) {
             System.out.println("Way to Go Player 2! O Wins, Game Over.");
         }

         // If Status Check passes (game still in progress), we need to reassign play for each new move until it completes
         CURRENT_PLAYER = (CURRENT_PLAYER == EXPLAY) ? OHPLAY : EXPLAY;
          } while (CURRENT_STATUS == GAME_IN_PROGRESS); 
       }
 
   //(Re)set game board and turn game_in_progress indicator on
   public static void startTicTacToe() {
      for (int r = 0; r < 3; ++r) {
         for (int c = 0; c < 3; ++c) {
            BOARD[r][c] = BLANK_CELL;
         }
      }
      CURRENT_STATUS = GAME_IN_PROGRESS; 
      CURRENT_PLAYER = EXPLAY;  //(Player EX opens)
   }
 
   // Player with current turn must make a move on an empty square or it will be rejected.
   public static void playNextMove(int currentMove) {
      boolean emptySquare = false;
      do {
         if (currentMove == EXPLAY) {
            System.out.print("Player 1, choose a square to place your X (input valid row [1-3] and valid column [1-3]): ");
         } else {
            System.out.print("Player 2, choose a square to place your O (input valid row [1-3] and valid column [1-3]): ");
         }
         int r = in.nextInt() - 1;  
         int c = in.nextInt() - 1;
         if (r >= 0 && r < 3 && c >= 0 && c < 3 && BOARD[r][c] == BLANK_CELL) {
            ROW = r;
            COLUMN = c;
            BOARD[ROW][COLUMN] = currentMove;  //set the chosen square to X or O
            emptySquare = true;  //confirm move is allowed
         } else {
            System.out.println("Square (" + (r + 1) + "," + (c + 1)
                  + ") is occupied. Please find an empty square to play your move.");
         }
      } while (!emptySquare);  // print error message until player chooses empty square
   }
 
   // Time to check if game progress continues or if game is over based on last move
   public static void processNextMove(int currentMove, int ROW, int COLUMN) {
      if (gameOver(currentMove, ROW, COLUMN)) {  // check if winning move
          CURRENT_STATUS = (currentMove == EXPLAY) ? EX_GAME : OH_GAME;
      } else if (catsGame()) {  
         CURRENT_STATUS = CATS_GAME;
      }
   }
 
   //Check for a full board. If the board is full and no one has Tic Tac Toe, the cat has won and the game is over.
   public static boolean catsGame() {
      for (int r = 0; r < 3; ++r) {
         for (int c = 0; c < 3; ++c) {
            if (BOARD[r][c] == BLANK_CELL) {
               return false;
            }
         }
      }
      return true;  
   }
 
   //Check for tic tac toe and identify winner based on who played the last move.
   //First we check to see if the player's chosen row has 3 of a kind.
   //Second, we check to see if the player's chosen column has 3 of a kind
   //Next we need to check diagonal lines
   public static boolean gameOver(int currentMove, int ROW, int COLUMN) {
      return (BOARD[ROW][0] == currentMove       
                   && BOARD[ROW][1] == currentMove
                   && BOARD[ROW][2] == currentMove
              || BOARD[0][COLUMN] == currentMove      
                   && BOARD[1][COLUMN] == currentMove  
                   && BOARD[2][COLUMN] == currentMove  
              || ROW == COLUMN         
                   && BOARD[0][0] == currentMove  
                   && BOARD[1][1] == currentMove  
                   && BOARD[2][2] == currentMove  
              || ROW + COLUMN == 2  
                   && BOARD[0][2] == currentMove  
                   && BOARD[1][1] == currentMove  
                   && BOARD[2][0] == currentMove  );
   }
 
   //
   public static void printLastMove() {
      for (int r = 0; r < 3; ++r) {
         for (int c = 0; c < 3; ++c) {
            printSpace(BOARD[r][c]); 
            if (c <2) {
               System.out.print("|");   
            }
         }
         System.out.println();
         if (r < 2) {
            System.out.println("-----------"); 
         }
      }
      System.out.println();
   }
 
   //Print a given square in the table
   public static void printSpace(int value) {
      switch (value) {
         case BLANK_CELL:  System.out.print("   "); break;
         case OHPLAY: System.out.print(" O "); break;
         case EXPLAY:  System.out.print(" X "); break;
      }
   }
}