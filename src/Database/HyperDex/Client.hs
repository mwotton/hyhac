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
  ( module Database.HyperDex.Internal.Client
  , module Database.HyperDex.Internal.Hyperdex
  , module Database.HyperDex.Internal.Hyperdata
  , module Database.HyperDex.Internal.Space
  , module Database.HyperDex.Internal.HyperdexClient
  -- Data structures
  , module Database.HyperDex.Internal.ReturnCode
  , module Database.HyperDex.Internal.Attribute
  , module Database.HyperDex.Internal.AttributeCheck
  , module Database.HyperDex.Internal.MapAttribute
  )
  where

import           Database.HyperDex.Internal.Attribute      (Attribute (..),
                                                            mkAttribute)
import           Database.HyperDex.Internal.AttributeCheck (AttributeCheck (..),
                                                            mkAttributeCheck)
import           Database.HyperDex.Internal.Client         (AsyncResult, Client,
                                                            ConnectInfo,
                                                            ConnectOptions,
                                                            Result,
                                                            SearchStream (..),
                                                            close, connect,
                                                            defaultConnectInfo, defaultConnectOptions)
import           Database.HyperDex.Internal.Hyperdata      (HyperSerialize,
                                                            datatype,
                                                            deserialize,
                                                            serialize)
import           Database.HyperDex.Internal.Hyperdex       (Hyperdatatype (..),
                                                            Hyperpredicate (..))
import           Database.HyperDex.Internal.HyperdexClient
import           Database.HyperDex.Internal.MapAttribute   (MapAttribute (..),
                                                            mkMapAttribute, mkMapAttributesFromMap)
import           Database.HyperDex.Internal.ReturnCode     (ReturnCode (..))
import           Database.HyperDex.Internal.Space
