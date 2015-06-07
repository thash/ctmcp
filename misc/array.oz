declare
A={NewArray 1 10 _} % 第三引数は初期化時に埋めるもの
{Browse A} % => <Array> 中見えない
{Browse A.1} % => _
A.1:=123
{Browse A.1} % => 123
{Browse {Array.get A 1}} %=> 123

declare
B={NewArray 1 10 1}
{Browse B.1} % => 1
{Browse B.4} % => 1