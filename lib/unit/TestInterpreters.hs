module TestInterpreters (
    testInterpreters
) where

import Test.Hspec

import TestInterpreters.TestRequestInterpreter
import TestInterpreters.TestSocketContextInterpreter

testInterpreters :: Spec
testInterpreters = do
    describe "test redis monad interpreters" $ do
        testSocketContextInterpreter
        testRequestInterpreter