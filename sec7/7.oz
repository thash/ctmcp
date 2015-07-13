%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                  7. オブジェクト指向プログラミング
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

他書で十分に説明されていない領域，つまり
  * 他の計算モデルとの関係
  * オブジェクト指向の正確な意味
  * 動的型付けの可能性
について紹介する．


%%% オブジェクト指向プログラミングの原則

* 第六章の状態ありモデルを基底にする
* プログラムは相互作用するデータ抽象の集まりである
  1. データ抽象はデフォルトで「状態あり」であるべき
  2. PDAスタイル(p.431)のデータ抽象がデフォルトであるべき．多態性と継承がやりやすいので.

> 継承により，抽象を漸増的に構築できる．継承を支援するために，クラスという言語抽象を追加する．

さらに情報を得るには Bertrand Meyer "Object-Oriented Software Construction" がオススメ.
継承に関する詳細な議論がおもしろいとのこと
翻訳されたものがよく見るコレだった

オブジェクト指向入門 第2版 原則・コンセプト (IT Architect’Archive クラシックモダン・コンピューティング)
バートランド・メイヤー, 酒匂 寛
http://www.amazon.co.jp/dp/4798111112


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 7.1. 継承
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

継承という概念を導入してコード重複を減らし，データ抽象の間の関係を明らかにする．
データ抽象の漸増的定義をクラス(class)という

> 継承は大いなる可能性ではあるが，経験によれば，大いに注意して使わなければならない．
* 祖先クラスについて十分知った上で変形を定義しないといけない
  * クラスの不変表明を破ってしまうことがある
* 継承を使うとあるコンポーネントに対して新しいインターフェイスが追加されることになり，
  そのコンポーネントが生きている間インターフェイスを維持しなければならない
* ある抽象の実装がプログラムのいたるところにばら撒かれることになる
  * 祖先クラスも読まないと実装が理解できない

継承の代用として「コンポーネントベースプログラミング」が考えられる．
不変表明を破ることなく直接コンポーネントを使い，合成できる．



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 7.4. 継承を使うプログラミング
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 継承をどう見るか?
% 1. 型である
%  クラスは型であり，代替性(substitution property)を満たす．
%  すなわちクラスCのオブジェクトのオブジェクトに使える操作はCの下位クラスのオブジェクトにも使える.
% 2. 構造である
%  プログラムを構造化するための1つのツールにすぎない, と. この見方は"全く進められない"
%  クラスが代替性を満たさないためあえである．


%% 契約による設計
% D言語，契約による設計をサポートしてたりする

%% 訓話 (読み物)

%% 7.4.2 型に従って階層を構成すること

%% 7.4.3 汎用クラス(generic class)
% 実現方法(1). 継承を使う
% 実現方法(2). 高階プログラミングを利用する

% fib 7.15 汎用クラスの使い方(継承バージョン)
% クイックソート
declare
class GenericSort
   meth init skip end
   meth qsort(Xs Ys)
      case Xs
      of nil then Ys = nil
      [] P|Xr then S L in
         {self partition(Xr P S L)}
         {Append {self qsort(S $)}
                 P|{self qsort(L $)} Ys}
      end
   end
   meth partition(Xs P Ss Ls)
      case Xs
      of nil then Ss=nil Ls=nil
      [] X|Xr then Sr Lr in
         if {self less(X P $)} then
            Ss=X|Sr Ls=Lr
         else
            Ss=Sr Ls=X|Lr
         end
         {self partition(Xr P Sr Lr)}
      end
   end
end

% fig 7.16
declare
class IntegerSort from GenericSort
   meth less(X Y B)
      B=(X<Y)
   end
end

class RationalSort from GenericSort
   meth less(X Y B)
      '/'(P Q)=X
      '/'(R S)=Y
   in B=(P*S<Q*R) end
end


% fig 7.18
declare
fun {MakeSort Less}
   class $
      meth init skip end
      meth qsort(Xs Ys)
         case Xs
         of nil then Ys = nil
         [] P|Xr then S L in
            {self partition(Xr P S L)}
            {Append {self qsort(S $)}
                    P|{self qsort(L $)} Ys}
         end
      end
      meth partition(Xs P Ss Ls)
         case Xs
         of nil then Ss=nil Ls=nil
         [] X|Xr then Sr Lr in
            if {Less X P} then
               Ss=X|Sr Ls=Lr
            else
               Ss=Sr Ls=X|Lr
            end
            {self partition(Xr P Sr Lr)}
         end
      end
   end
end

% fig 7.19
declare
IntegerSort = {MakeSort fun {$ X Y} X<Y end}

RationalSort = {MakeSort fun {$ X Y}
                            '/'(P Q) = X
                            '/'(R S) = Y
                         in P*S<Q*R end}


% Rationalの書き方.


%% 7.4.4 多重継承
% そもそもなるべく継承を避けるというのが方針であるべきなのであんま現場では使わない
% 多重継承は要はmixin
% trait = mixin用の専用のモノ
