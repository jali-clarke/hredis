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
        describe "get" $ do
            it "should translate a get into its serialized request" $
                asRequest (get "key") `shouldBe` "*2\r\n$3\r\nGET\r\n$3\r\nkey\r\n"
            it "should translate a get into its serialized request different key" $
                asRequest (get "different_key") `shouldBe` "*2\r\n$3\r\nGET\r\n$13\r\ndifferent_key\r\n"
        describe "set" $ do
            it "should translate a set into its serialized request" $
                asRequest (set "key" "value") `shouldBe` "*3\r\n$3\r\nSET\r\n$3\r\nkey\r\n$5\r\nvalue\r\n"
            it "should translate a set into its serialized request different key" $
                asRequest (set "cool" "value") `shouldBe` "*3\r\n$3\r\nSET\r\n$4\r\ncool\r\n$5\r\nvalue\r\n"
            it "should translate a set into its serialized request different value" $
                asRequest (set "cool" "boible") `shouldBe` "*3\r\n$3\r\nSET\r\n$4\r\ncool\r\n$6\r\nboible\r\n"