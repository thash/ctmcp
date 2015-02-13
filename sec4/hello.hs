fib :: Integer -> Integer
fib 1 = 1
fib 2 = 1
fib n = fib (n - 1) + fib (n - 2)

main = do putStrLn "Hello Haskell!"
          print(fib 10)
