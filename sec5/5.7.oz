%%% Erlang流 receiveの実装

%% 第1形式(時間切れなし)
local
   fun {Loop S T#E Sout}
      case S of M|S1 then
         case M
         of T(Pattern1) then E=S1 T(Body1 T Sout)
         % ...
         [] T(PatternN) then E=S1 T(BodyN T Sout)
         else E1 in E=M|E1 {Loop S1 T#E1 Sout}
         end
      end
   end T
in
   {Loop Sin T#T Sout}
end

% どのパターンにもマッチしないメッセージを受け取ったら標準出力(Sout)に入れる


%% 第2形式(時間切れあり)
local
   Cancel={Alarm T(Expr)} % Alarmによるタイマ割り込み
   fun {Loop S T#E Sout}
      if {WaitTwo S Cancel}==1 then % この"1"に深い意味はなくWaitTwoの実装依存．詳細下記
         case S of M|S1 then
            case M
            of T(Pattern1) then E=S1 T(Body1 T Sout)
            % ...
            [] T(PatternN) then E=S1 T(BodyN T Sout)
            else E1 in E=M|E1 {Loop S1 T#E1 Sout} end
         end
      else E=S T(BodyT T Sout) end
   end T
in
   {Loop Sin T#T Sout}
end

% {Alarm N}は4.6節(p.315)で定義したものを想定しており，
% 少なくともNミリ秒待ち，そのあと束縛されていない変数Cancelにunitを束縛する．

% WaitTwoの実装は本書のWebサイトに載ってるが，概要としては「2つのイベントのうち1つを待つ」
% 今回のケースでは(1)メッセージ受信=Sの束縛, (2)タイムアウト=Cancelの束縛いずれかを待っている．
% 最初の引数が束縛されれば1を返し，2個目なら2．


%% 第3形式(猶予時間0の時間切れあり)
% 猶予時間0とはつまりreceiveがブロックしないということ．
% 第2形式より簡単に実装できる．

if {IsDet Sin} then
   case Sin of M|S1 then
      case M
      of T(Pattern1) then T(Body1 S1 Sout)
         % ...
      [] T(PatternN) then T(BodyN S1 Sout)
      else T(BodyT Sin Sout) end
   end
else Sout=Sin end
