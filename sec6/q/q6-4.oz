% ポートを実装すること
% ポートは状態ありADTである. 6.4章の技法によりセルを使ってポートを実装せよ.

{NewPort S P} % ストリームSを持つポートPを返す
{Send P X}    % ポートPにメッセージXを送る

% p.436
declare
fun {NewPort2 S}
   C={NewCell nil}
   proc {Send2 X}
      % ...?
      C:=@C|X
   end
in
   port(send:Send2)
end


declare S P
P={NewPort2 S}
{Browse P}
{P.send 22}