module Main where
-- Haskell
-- cabal install ghc-modしてghcmod-vimを利用
-- 実用的で，完全に宣言的な言語を定義しようとする試みのうち最も成功したもの
-- 非正格，強く片付けされた関数型言語で，カリー化とモナド的プログラミングスタイルを支援．
-- * 強く片付けされた = コンパイル時にすべての式の型が判明して，すべての関数適用が型について正しくなければならない
-- * モナド的スタイル(monadic style) = 高階プログラミング技法の集合で，
--   多くの場合明示的状態を置き換えるのに使える

factorial :: Integer -> Integer
factorial 0 = 1
factorial n | n > 0 = n * factorial (n-1)
factorial _ = error "waiwai"
-- CTMCPに書かれてないerror行を入れないと，以下のように怒られる．
-- 4.7.hs|10 col 1 warning| Pattern match(es) are non-exhaustive
-- || In an equation for ‘factorial’: Patterns not matched: _

main :: IO ()
main =
  if factorial 10 > 10
    then putStrLn "hello"
    else putStrLn "bye"


-- 非正格である = 必要になるまで計算しない
-- Haskellコンパイラは正格性解析(strictness analysis)を行い，
-- 遅延にしなくて良い関数は性急(正格(strict))関数としてコンパイルされる．

-- 型指定忘れるとこんな感じに怒る
-- 4.7.hs|29 col 1 warning| Top-level binding with no type signature:
sqrt :: Float -> Float
sqrt x = head (dropWhile (not . goodEnough) sqrtGuesses)
  where
    -- absとmapの()がredundantとの警告があったので外す
    goodEnough guess = abs (x - guess*guess)/x < 0.00001
    improve guess = (guess + x/guess)/2.0
    sqrtGuesses = 1:map improve sqrtGuesses -- :はOzの|と同じ，リスト生成操作


-- 4.7.3 カリー化
doubleList :: [Integer] -> [Integer]
doubleList = map (\x -> 2*x)

-- doubleList [1,2,3,4]
-- => map (\x -> 2*x) [1,2,3,4]
-- => [2,4,6,8]

-- 4.7.4 多態型
data BinTree a = Empty | Node a (BinTree a) (BinTree a)

-- sizeのredundant bracketとval未使用が警告されたので修正
size :: BinTree a -> Integer
size Empty = 0
size (Node _ lt rt) = 1 + size lt + size rt

-- パターンマッチしたものの未使用の変数が警告されるので_で捨てる
-- また，CTMCPにはないけど追加最後のパターンがないよと言われたので
lookupBinTree :: Integer -> BinTree (Integer,String) -> Maybe String
lookupBinTree _ Empty = Nothing
lookupBinTree k (Node (nk,nv) _ _) | k == nk = Just nv
lookupBinTree k (Node (nk,_) lt _) | k  < nk = lookupBinTree k lt
lookupBinTree k (Node (nk,_) _ rt) | k  > nk = lookupBinTree k rt
lookupBinTree _ (Node (_,_) _ _) = error "not found?"


-- Haskellの型クラス(type class)は，関数のグループに名前をつける機能
-- さっきのlookupは ==, <, >を支援するOrdという組み込み型クラスを使うといい感じに書ける．
