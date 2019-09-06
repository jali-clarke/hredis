module TestInterpreters (
    testInterpreters
) where

import Test.Hspec

import TestInterpreters.TestRequestInterpreter
import TestInterpreters.TestSocketContextInterpreter

testInterpreters :: Spec
testInterpreters = do
    describe "test redis edsl interpreters" $ do
        testSocketContextInterpreter
        testRequestInterpreter