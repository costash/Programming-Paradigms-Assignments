-- Constantin Serban-Radoi 323CA
-- Tema 2 PP
-- Aprilie 2012

module Robot
where

import Types
import Random
import System.IO.Unsafe

{-
The type memory holds a tuple of three elements: first is the list of forbidden
places; second is the current position; third is a list of visited positions
-}
type Memory = (Size, Point, [Point])

{-
When the robot enters the mine it receives as input the size of the mine (it
is always placed at (0, 0)). This function should return the initial memory
element of the robot.
-}
startRobot :: Size -> Memory
startRobot size = (size, (0, 0), [])

{-
Pick a random element from a list
-}
pick :: [a] -> IO a
pick xs = randomRIO (0, (length xs - 1)) >>= return . (xs !!)

{-
Pick a random direction and move to that only if it is valid. The current
position and the list of visited positions are also updated
-}
-- randomWalk :: [Cardinal] -> Size -> Point -> [Point] -> (Action, Memory)
randomWalk cs size pos list =
	unsafePerformIO $ do
		dir <- pick [E, S, W, N]
		if dir == E && not (E `elem` cs)
		then return (Just E, (size, (fst(pos), snd(pos) + 1), (pos:list)))
		else if dir == S && not (S `elem` cs) 
		then return (Just S, (size, (fst(pos) + 1, snd(pos)), (pos:list)))
		else if dir == W && not (W `elem` cs) 
		then return (Just W, (size, (fst(pos), snd(pos) - 1), (pos:list)))
		else if dir == N && not (N `elem` cs) 
		then return (Just N, (size, (fst(pos) - 1, snd(pos)), (pos:list)))
		else return (Nothing, (size, pos, list))

{-
At each time step the robot sends a light beam in all 4 cardinal directions,
receives the reflected rays and computes their intensity (the first argument
of the function).

The robot sees nearby pits. The second argument of this function is the list
of neighbouring pits near the robot (if empty, there are no pits).

Taking into account the memory of the robot (third argument of the function),
it must return a tuple containing a new cardinal direction to go to and a new
memory element.

If the cardinal direction chosen goes to a pit or an wall the robot is
destroyed. If the new cell contains minerals they are immediately collected.
-}

{-
Take directions in this order: E, S, W, N; If a valid move can be done in a
direction, the current position and the list of visited positions are updated
and the move is returned

If no *unvisited* and *legal* move is available, the function randomWalk is
called to make a random legal move.
-}
--percieveAndAct :: SVal -> [Cardinal] -> Memory -> (Action, Memory)
perceiveAndAct s cs (size, pos, list)
	| not (E `elem` cs) && not ((fst(pos), snd(pos) + 1) `elem` list) = 
		(Just E, (size, (fst(pos), snd(pos) + 1), (pos:list)))
	| not (S `elem` cs) && not ((fst(pos) + 1, snd(pos)) `elem` list) = 
		(Just S, (size, (fst(pos) + 1, snd(pos)), (pos:list)))
	| not (W `elem` cs) && not ((fst(pos), snd(pos) - 1) `elem` list) = 
		(Just W, (size, (fst(pos), snd(pos) - 1), (pos:list)))
	| not (N `elem` cs) && not ((fst(pos) - 1, snd(pos)) `elem` list) = 
		(Just N, (size, (fst(pos) - 1, snd(pos)), (pos:list)))
	| otherwise = (randomWalk cs size pos list)
