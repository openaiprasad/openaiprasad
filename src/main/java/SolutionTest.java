import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;



public class SolutionTest {

	
	@Test
	public void testStartGame() {
		Solution.initGame(6);
		Solution.addShip("SH1", 2, 1, 5, 4, 4);
		Assertions.assertFalse(Solution.startGame(3, 0));
		Assertions.assertFalse(Solution.startGame(1, 1));
		Assertions.assertTrue(Solution.startGame(4, 3));
	}
	
	@Test
	public void testInitGame() {
		Solution.initGame(6);
		Assertions.assertEquals(Solution.shipPos[0][1], 0);
	}
}
