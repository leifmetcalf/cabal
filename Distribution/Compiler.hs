-----------------------------------------------------------------------------
-- |
-- Module      :  Distribution.Compiler
-- Copyright   :  Isaac Jones 2003-2004
-- 
-- Maintainer  :  Isaac Jones <ijones@syntaxpolice.org>
-- Stability   :  alpha
-- Portability :  portable
--
-- Haskell compiler flavors

{- All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.

    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.

    * Neither the name of Isaac Jones nor the names of other
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. -}

module Distribution.Compiler (
  -- * Compiler flavor
  CompilerFlavor(..),
  showCompilerFlavor,
  readCompilerFlavor,
  buildCompilerFlavor,
  defaultCompilerFlavor,

  -- * Compiler id
  CompilerId(..),
  showCompilerId,
  ) where

import Distribution.Version (Version(..))

import qualified System.Info (compilerName)
import qualified Data.Char as Char (toLower)
import Distribution.Text (display)

data CompilerFlavor = GHC | NHC | YHC | Hugs | HBC | Helium | JHC
                    | OtherCompiler String
  deriving (Show, Read, Eq, Ord)

knownCompilerFlavors :: [CompilerFlavor]
knownCompilerFlavors = [GHC, NHC, YHC, Hugs, HBC, Helium, JHC]

showCompilerFlavor :: CompilerFlavor -> String
showCompilerFlavor (OtherCompiler name) = name
showCompilerFlavor NHC                  = "nhc98"
showCompilerFlavor other                = lowercase (show other)

readCompilerFlavor :: String -> CompilerFlavor
readCompilerFlavor s =
  case lookup (lowercase s) compilerMap of
    Just arch -> arch
    Nothing   -> OtherCompiler (lowercase s)
  where
    compilerMap = [ (showCompilerFlavor compiler, compiler)
                  | compiler <- knownCompilerFlavors ]

buildCompilerFlavor :: CompilerFlavor
buildCompilerFlavor = readCompilerFlavor System.Info.compilerName

defaultCompilerFlavor :: Maybe CompilerFlavor
defaultCompilerFlavor = case buildCompilerFlavor of
  OtherCompiler _ -> Nothing
  _               -> Just buildCompilerFlavor

-- ------------------------------------------------------------
-- * Compiler Id
-- ------------------------------------------------------------

data CompilerId = CompilerId CompilerFlavor Version
  deriving (Eq, Ord, Read, Show)

showCompilerId :: CompilerId -> String
showCompilerId (CompilerId f (Version [] _)) = showCompilerFlavor f
showCompilerId (CompilerId f v) = showCompilerFlavor f ++ '-': display v

lowercase :: String -> String
lowercase = map Char.toLower
