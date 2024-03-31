import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Scanner;

public class Solution {

	static int shipPos[][] = null;
	static  List<String> player1Pos= new ArrayList<>();
	
	static List<String> player2Pos= new ArrayList<>();

	static int n = 0;
	
	public static void initGame(int N) {
		shipPos = new int[N][N];
		n = N;
		for(int i=N-1;i<=0;i--) {
		
			for(int j=N-1;j<=0;j--) {
			shipPos[i][j] = 0;
			}
		}
	}
	
	public static void addShip(String id, int size, int a, int b , int x, int y) {
		
		for(int i=a;i<a+size && i<n;i++) {
			for(int j=b;j<b+size && i<n;j++) {
				player1Pos.add(i+":"+j);
			}
		}
		
		for(int i=x;i>x-size;i--) {
			for(int j=y;j>y-size;j--) {
				player2Pos.add(i+":"+j);
			}
		}
		
	}
	
	public static List<String> viewBattleField(String ship) {
		if(ship.equalsIgnoreCase("SH1")) {
			return player1Pos;
		}
		return player2Pos;
		
	}
	
	public static boolean  startGame(int x,int y) {
		
		if(player1Pos.contains(x+":"+y)) {
			System.out.println("Ship 1 destroyed");
			return true;
			
		}
		if(player2Pos.contains(x+":"+y)) {
			System.out.println("Ship 2 destroyed");
			return true;
			
		}
		return false;
	}

	public static void main(String[] args) {
		initGame(6);
		addShip("SH1", 2, 1, 5, 4, 4);
		System.out.println(player1Pos);
		System.out.println(player2Pos);
		Scanner scanner = new Scanner(System.in);
		System.out.println("Enter Player pos");
		Boolean isDestroyed = false;
		while(!isDestroyed) {
			int x = scanner.nextInt();
			int y = scanner.nextInt();
			isDestroyed = startGame(x,y);
		}
		
		List<String> positionsShip1 = viewBattleField("SH1");
		System.out.println("Printing Ship1 Position");
		positionsShip1.stream().forEach(pos->{
			System.out.println(pos);
		});
		
		System.out.println("\nPrinting Ship2 Position");
		List<String> positionsShip2 = viewBattleField("SH2");
		positionsShip2.stream().forEach(pos->{
			System.out.println(pos);
		});
	}
}
