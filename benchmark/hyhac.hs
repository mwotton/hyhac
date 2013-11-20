{-# LANGUAGE OverloadedStrings #-}
import           Criterion.Main
import qualified Database.HyperDex          as H
import qualified Database.HyperDex.Admin    as HA
-- import qualified Database.Cassandra.Basic as C
import           Control.Applicative
import           Control.DeepSeq
import           Control.Monad
import           System.Environment         (getEnv)

import qualified Data.ByteString.Char8      as BS
import qualified Data.ByteString.Lazy.Char8 as BSL
import           Data.Either                (lefts)
import qualified Data.Text                  as Text
import qualified Data.Text.IO               as Text

import qualified Control.Exception          as E
import qualified Database.SQLite3           as SQL
import           System.Cmd
import           System.IO

instance NFData H.Attribute where
  rnf (H.Attribute a b c) = a `seq` b `seq` c `seq` ()

main :: IO ()
main = do
  reps <- read  <$> getEnv "REPS"
  -- threaded <- (=="yes")  <$> getEnv "THREADED"

  _ <- system "rm dummysql"
  _ <- system "rm dummyfile"

  ws <- BS.lines <$> BS.readFile "/usr/share/dict/words"
  wsl <- BSL.lines <$> BSL.readFile "/usr/share/dict/words"
  wst <- Text.lines <$> Text.readFile "/usr/share/dict/words"

  let
      lastname = BS.take 50 $!! BS.unlines ws
      lastnamel = BSL.take 50 $!! BSL.unlines wsl
      lastnamet = Text.take 50
                  $!! Text.unlines wst

      testrun = take reps $!! ws
      testrunl = take reps $!! wsl
      testrunt = take reps $!! wst

  return $ rnf lastname
--  return $ rnf testrun
  return $ rnf lastnamet
  --return $ rnf testrunt
  return $ rnf lastnamel
--  return $ rnf testrunl

  -- pool <- C.createCassandraPool C.defServers 3 300 5 "testkeyspace"

  client <- H.connect H.defaultConnectInfo
  admin <- HA.connect H.defaultConnectInfo

  E.handle ignore $ void $ (H.removeSpace admin "phonebook" >>   HA.hyperdex_waitUntilStable admin)
  _ <- H.addSpace admin
       $ Text.unlines
         [ "space phonebook"
         , "key username"
         , "attributes content"
         -- , "subspace first, last"
         , "create 32 partitions"
         , "tolerate 0 failures"
         ]
  HA.hyperdex_waitUntilStable admin

  db <- SQL.open "dummysql"
  SQL.execPrint db "PRAGMA journal_mode=MEMORY; PRAGMA synchronous = OFF"

  SQL.exec db "create table phonebook (username txt, content text);"
  stmt <- SQL.prepare db "insert into phonebook (username, content) values (?,?);"

  --file <- openFile "/dev/null" WriteMode

  let -- finish :: ((BS.ByteString, BSL.ByteString, Text.Text) -> IO a) -> ([a] -> IO ()) -> IO ()
      finish work ender = mapM work (zip3 testrun testrunl testrunt) >>= ender

  putStrLn "starting"
  defaultMain [
               bench "sqlite" $ do
                  SQL.execPrint db "begin transaction;"
                  finish ( \(_,_,x) -> do
                           SQL.bind stmt [SQL.SQLText x, SQL.SQLText lastnamet]
                           SQL.step stmt
                           SQL.reset stmt)
                    ( \_ -> SQL.execPrint db "end transaction;"  ),
               -- bench "file" $ do
               --   file <- openFile "./dummyfile" WriteMode
               --   finish (\(x,_,_) ->
               --            BS.hPutStrLn file $ BS.unlines [x, lastname])
               --     (\_ -> hClose file),
               -- bench "cassandra" $ finish (\(_,x,_) -> return $
               --                                C.insert  "phonebook" x C.ANY
               --                                  [ C.col "last" lastnamel
               --                                  ])
               --                            (\insertions ->  void $ C.runCas pool $ sequence insertions),
               bench "hyperdex" $ finish (\(x,_,_) ->
                                           H.put client "phonebook" x $!!
                                             [H.mkAttribute "content"  lastname])
                                         (\actions -> do
                                             failures <- lefts <$> sequence actions
                                             when (failures /= []) $
                                               error ("failure in hyperdex: " ++ show failures)
                                             return ())
              ]


  -- void $ system "echo 'use testkeyspace; drop table phonebook;' | cqlsh"

  _ <- system "rm dummysql"
  _ <- system "rm dummyfile"

  return ()

ignore :: E.SomeException -> IO ()
ignore _ = return ()
