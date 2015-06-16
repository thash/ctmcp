% ポートを実装すること
% ポートは状態ありADTである. 6.4章の技法によりセルを使ってポートを実装せよ.

{NewPort S P} % ストリームSを持つポートPを返す
{Send P X}    % ポートPにメッセージXを送る


% p.209 名前(name)という基本型
% {NewName} で新しい名前を生成
% N1==N2 で名前を比較

% p.436
declare
fun {NewPort2 S}
   Key={NewName}
in
   port(send:Send2)
end

{Browse {NewName}}

declare S P
P={NewPort2 S}
{Browse P}
{P.send 22}

% ref: https://github.com/Altech/ctmcp-answers/blob/master/Section06/expr4.oz
declare
proc {NewWrapper Wrap Unwrap}
   Key={NewName} in
   fun {Wrap X}
      {Chunk.new w(Key:X)}
   end
   fun {Unwrap W}
      try W.Key catch _ then raise error(unwrap(W)) end end
   end
end

declare NewPort Send
local Wrap Unwrap in
   {NewWrapper Wrap Unwrap}
   proc {NewPort Stream Port} S in
      Port={Wrap {NewCell S}}
      Stream=!!S
   end
   proc {Send Port X} P in
      try
	 P = {Unwrap Port}
      catch _ then
	 {Browse typerror}
      end
      local Si|Sr=@P in
	 Si = X
	 P := Sr
      end
   end
end

declare S P
{NewPort S P}
{Send P asdf}

{Browse P}
{Browse {Send P ffff $}}