{-# LANGUAGE
    OverloadedStrings
#-}

module TestInterpreters.TestRequestInterpreter (
    testRequestInterpreter
) where

import Test.Hspec

import Redis
import Interpreters.RequestInterpreter

testRequestInterpreter :: Spec
testRequestInterpreter = do
    describe "asRequest" $ do
        it "should translate a get into its serialized request" $
            asRequest (get "key") `shouldBe` "*2\r\n$3\r\nGET\r\n$3\r\nkey\r\n"
        it "should translate a get into its serialized request different key" $
            asRequest (get "different_key") `shouldBe` "*2\r\n$3\r\nGET\r\n$13\r\ndifferent_key\r\n"