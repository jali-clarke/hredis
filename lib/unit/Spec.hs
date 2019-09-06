import Test.Hspec

import TestInterpreters

main :: IO ()
main = hspec $ do
    describe "lib unit tests" $ do
        testInterpreters