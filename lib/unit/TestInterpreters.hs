module TestInterpreters (
    testInterpreters
) where

import Test.Hspec

import TestInterpreters.TestSocketContextInterpreter

testInterpreters :: Spec
testInterpreters = do
    describe "test redis monad interpreters" $ do
        testSocketContextInterpreter