{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE StandaloneDeriving #-}
{-# LANGUAGE TemplateHaskell #-}

module Apps.Juno.JsonTypes where

import           Data.Aeson (encode
                            , decode
                            , genericParseJSON
                            , genericToJSON
                            , parseJSON
                            , toJSON
                            , ToJSON
                            , FromJSON
                            )
import           Data.Aeson.Types (defaultOptions
                                 , Options(..))
import qualified Data.ByteString.Lazy.Char8 as BL
import           GHC.Generics
import qualified Data.Text as T
import           Data.Text (Text)

removeUnderscore :: String -> String
removeUnderscore = drop 1

data Digest = Digest { _hash :: Text, _key :: Text } deriving (Eq, Generic, Show)

instance ToJSON Digest where
    toJSON = genericToJSON $ defaultOptions { fieldLabelModifier = removeUnderscore }
instance FromJSON Digest where
    parseJSON  = genericParseJSON $ defaultOptions { fieldLabelModifier = removeUnderscore }


data AccountPayload = AccountPayload { _account :: Text } deriving (Eq, Generic, Show)

instance ToJSON AccountPayload where
    toJSON = genericToJSON $ defaultOptions { fieldLabelModifier = removeUnderscore }
instance FromJSON AccountPayload where
    parseJSON = genericParseJSON $ defaultOptions { fieldLabelModifier = removeUnderscore }


data CreateAccountRequest = CreateAccountRequest {
      _payload :: AccountPayload,
      _digest :: Digest
    } deriving (Eq, Generic, Show)

instance ToJSON CreateAccountRequest where
    toJSON = genericToJSON $ defaultOptions { fieldLabelModifier = removeUnderscore }
instance FromJSON CreateAccountRequest where
    parseJSON = genericParseJSON $ defaultOptions { fieldLabelModifier = removeUnderscore }

data CreateAccountResponse = CreateAccountResponse {
      _cmdid :: Text
    , _status :: Text
    } deriving (Eq, Generic, Show)

instance ToJSON CreateAccountResponse where
    toJSON = genericToJSON $ defaultOptions { fieldLabelModifier = removeUnderscore }
instance FromJSON CreateAccountResponse where
    parseJSON = genericParseJSON $ defaultOptions { fieldLabelModifier = removeUnderscore }

createAccountResponseSuccess :: Text -> CreateAccountResponse
createAccountResponseSuccess cid = CreateAccountResponse cid "Success"

createAccountResponseFailure :: Text -> CreateAccountResponse
createAccountResponseFailure cid = CreateAccountResponse cid "Failure"

-- Tests
test :: Bool
test = testCAEncode && testCAEncode && testCADecode'

bytesCreateAccount :: BL.ByteString
bytesCreateAccount = BL.pack "{\"digest\":{\"hash\":\"hashy\",\"key\":\"mykey\"},\"payload\":{\"account\":\"TSLA\"}}"

bytesDigest :: BL.ByteString
bytesDigest = BL.pack "{\"hash\":\"hashy\",\"key\":\"mykey\"}"

testCADecode :: Bool
testCADecode =  (decode bytesCreateAccount :: Maybe CreateAccountRequest) == (Just (CreateAccountRequest {_payload = AccountPayload {_account = "TSLA"}, _digest = Digest {_hash = "hashy", _key = "mykey"}}))

testCADecode' :: Bool
testCADecode' = case (decode bytesCreateAccount :: Maybe CreateAccountRequest) of
                  Just (CreateAccountRequest (AccountPayload _) _) -> True
                  Nothing -> False

testDecodeDigest :: Bool
testDecodeDigest = case (decode bytesDigest :: Maybe Digest) of
                     Just (Digest _ _) -> True
                     Nothing -> False
testCAEncode :: Bool
testCAEncode = (encode (CreateAccountRequest (AccountPayload (T.pack "TSLA")) (Digest (T.pack "hashy") (T.pack "mykey")))) == ("{\"payload\":{\"account\":\"TSLA\"},\"digest\":{\"hash\":\"hashy\",\"key\":\"mykey\"}}")
