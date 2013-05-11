module QACG.CircGen.Bit.MCToff
( mcToff
  ,mkMcToff
) where


import QACG.CircUtils.Circuit
import QACG.CircUtils.CircuitState
import Control.Monad.State

import QACG.CircGen.Bit.Toffoli

mcToff :: [String] -> String -> CircuitState ()
mcToff conts targ = reduceCont conts []
  where reduceCont (x:y:xs) red = do c <- getConst 1
                                     leftTof x y (head c)    
                                     reduceCont xs $ head c : red
                                     rightTof x y (head c)
                                     freeConst c
        reduceCont (x:[]) red = reduceCont [] (x:red)
        reduceCont []     red | length red > 1 = reduceCont red []
                              | otherwise = cnot (head red) targ

mkMcToff:: [String] -> String -> Circuit
mkMcToff controls target = circ
  where (_,(_,_,circ)) = runState go ([], ['c':show x | x <- [0 .. (2*length controls)]], Circuit (LineInfo [] [] [] []) [] [])
        go             = do _ <- initLines controls
                            mcToff controls target
                            _ <- initLines [target]
                            setOutputs $ controls ++ [target]