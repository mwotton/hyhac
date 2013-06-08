{-# LANGUAGE ViewPatterns #-}

-----------------------------------------------------------------------------
-- |
-- Module      :  Data.HyperDex.Client
-- Copyright   :  (c) Aaron Friel 2013
-- License     :  BSD-style
-- Maintainer  :  mayreply@aaronfriel.com
-- Stability   :  maybe
-- Portability :  portable
--
-- A client connection based API for the HyperDex key value store.
--
-- This module exposes functions that rely on manually providing a client 
-- parameter, and no guarantees are provided that resources will be cleaned
-- up unless the end-user ensures the connection is closed.
--
-----------------------------------------------------------------------------

module Database.HyperDex.Client 
  ( Client
  , connect, close
  , ConnectInfo
  , defaultConnectInfo
  , ConnectOptions
  , defaultConnectOptions
  , addSpace, removeSpace
  , getAsyncAttr, putAsyncAttr
  , putIfNotExistAsync
  , deleteAsync
  , putConditionalAsyncAttr
  , putAtomicAdd, putAtomicSub
  , putAtomicMul, putAtomicDiv
  , putAtomicMod
  , putAtomicAnd, putAtomicOr
  , putAtomicXor
  , ReturnCode (..)
  , Attribute (..)
  , mkAttribute
  , AsyncResult, Result
  , Hyperdatatype (..)
  , HyperSerialize
  , serialize, deserialize, datatype
  , Hyperpredicate (..)
  )
  where

import Database.HyperDex.Internal.Client ( 
        Client, connect, close, AsyncResult, Result
      , ConnectInfo, defaultConnectInfo
      , ConnectOptions, defaultConnectOptions
      )
import Database.HyperDex.Internal.Hyperclient
import Database.HyperDex.Internal.Hyperdex (Hyperdatatype (..), Hyperpredicate (..))
import Database.HyperDex.Internal.Hyperdata (HyperSerialize, serialize, deserialize, datatype)
import Database.HyperDex.Internal.ReturnCode (ReturnCode (..))
import Database.HyperDex.Internal.Attribute (Attribute (..), mkAttribute)
import Database.HyperDex.Internal.AttributeCheck (AttributeCheck (..))
import qualified Database.HyperDex.Internal.Space as Space (addSpace, removeSpace)

import Data.ByteString (ByteString)

import Data.Text (Text)
import Data.Text.Encoding (encodeUtf8)

import Debug.Trace

-- | Create a space from a definition.
addSpace :: Client -> Text -> IO ReturnCode
addSpace client (encodeUtf8 -> spaceDef) = Space.addSpace client spaceDef

-- | Remove a space by name.
removeSpace :: Client -> Text -> IO ReturnCode
removeSpace client (encodeUtf8 -> space) = Space.removeSpace client space

-- | Retrieve a value from a space by key.
getAsyncAttr :: Client -> Text -> ByteString -> AsyncResult [Attribute]
getAsyncAttr client (encodeUtf8 -> space) key =
  hyperGet client space key

-- | Put a value in a space by key.
putAsyncAttr :: Client -> Text -> ByteString -> [Attribute] -> AsyncResult ()
putAsyncAttr client (encodeUtf8 -> space) key attrs = 
  hyperPut client space key attrs

putIfNotExistAsync :: Client -> Text -> ByteString -> [Attribute] -> AsyncResult ()
putIfNotExistAsync client (encodeUtf8 -> space) key attrs = 
  hyperPutIfNotExist client space key attrs

deleteAsync :: Client -> Text -> ByteString -> AsyncResult ()
deleteAsync client (encodeUtf8 -> space) key = 
  hyperDelete client space key

putConditionalAsyncAttr :: Client -> Text -> ByteString -> [AttributeCheck] -> [Attribute] -> AsyncResult ()
putConditionalAsyncAttr client (encodeUtf8 -> space) key checks attrs = 
  hyperPutConditionally client space key checks attrs

putAtomicAdd :: Client -> Text -> ByteString -> [Attribute] -> AsyncResult ()
putAtomicAdd client (encodeUtf8 -> space) key attrs = 
  hyperAtomicAdd client space key attrs

putAtomicSub :: Client -> Text -> ByteString -> [Attribute] -> AsyncResult ()
putAtomicSub client (encodeUtf8 -> space) key attrs = 
  hyperAtomicSub client space key attrs

putAtomicMul :: Client -> Text -> ByteString -> [Attribute] -> AsyncResult ()
putAtomicMul client (encodeUtf8 -> space) key attrs =
  hyperAtomicMul client space key attrs

putAtomicDiv :: Client -> Text -> ByteString -> [Attribute] -> AsyncResult ()
putAtomicDiv client (encodeUtf8 -> space) key attrs = 
  hyperAtomicDiv client space key attrs

putAtomicMod :: Client -> Text -> ByteString -> [Attribute] -> AsyncResult ()
putAtomicMod client (encodeUtf8 -> space) key attrs = 
  hyperAtomicMod client space key attrs

putAtomicAnd :: Client -> Text -> ByteString -> [Attribute] -> AsyncResult ()
putAtomicAnd client (encodeUtf8 -> space) key attrs = 
  hyperAtomicAnd client space key attrs

putAtomicOr :: Client -> Text -> ByteString -> [Attribute] -> AsyncResult ()
putAtomicOr client (encodeUtf8 -> space) key attrs = 
  hyperAtomicOr client space key attrs

putAtomicXor :: Client -> Text -> ByteString -> [Attribute] -> AsyncResult ()
putAtomicXor client (encodeUtf8 -> space) key attrs = 
  hyperAtomicXor client space key attrs
