{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE ScopedTypeVariables #-}

module NFunction
    ( NFunction
    , ($*)
    , ComposeN
    , compose
    ) where

import TypeLevelNat (Z(..), S(..), Nat)
import SizedList    (SizedList(..))

-- | A @NFunction n a b@ is a function which takes @n@ arguments of
-- type @a@ and returns a @b@.
-- For example: NFunction (S (S (S Z))) a b ~ (a -> a -> a -> b)
type family NFunction n a b :: *

type instance NFunction Z     a b = b
type instance NFunction (S n) a b = a -> NFunction n a b

-- | @f $* xs@ applies the /n/-arity function @f@ to each of the arguments in
-- the /n/-sized list @xs@.
($*) :: NFunction n a b -> SizedList n a -> b
f $* Nil        = f
f $* (x ::: xs) = f x $* xs

infixr 0 $* -- same as $

class Nat n => ComposeN n where
    compose :: forall a b c. n -> a -> (b -> c) -> NFunction n a b -> NFunction n a c

instance ComposeN Z where
    compose Z _ = ($)

instance ComposeN n => ComposeN (S n) where
    compose (S n) (_ :: a) f g = compose n (undefined :: a) f . g

{-
TODO: The following does not work as expected.
See: http://www.haskell.org/pipermail/haskell-cafe/2009-August/065850.html

-- | @f .* g@ composes @f@ with the /n/-arity function @g@.
(.*) :: forall n a b c. (ComposeN n) => (b -> c) -> NFunction n a b -> NFunction n a c
(.*) = compose (witnessNat :: n) (undefined :: a)

infixr 9 .* -- same as .
-}
