https://github.com/ojima-h/ctmcp-reading/wiki


### 本に乗ってるソースコード

* https://www.info.ucl.ac.be/~pvr/bookfigures/
* https://www.info.ucl.ac.be/~pvr/ds/mitbook.html
  * http://www.info.ucl.ac.be/~pvr/ds/booksuppl.oz
  * https://www.info.ucl.ac.be/~pvr/ds/File.oz
  * ... etc


### install される Mozart2 のリソース

```
$ cd /Applications/Mozart2.app/Contents/Resources/share/mozart/
```


### Module.link について

https://mozart.github.io/mozart-v1/doc-1.4.0/apptut/node4.html


### 動作しないコード

* 9章のSolve
  * booksuppl.oz での定義内で利用しているSpaceが動作しない
* 11章のConnection
  * module load できない (x-oz://system/ 配下にいない)
  * `sec11/could_not_load_connection.oz`


Review
========================

* q2-9: 手で末尾再帰を計算.
* q4-17: Hamming数


Summary
======================

7. クラスとは属性名(リテラル)の集合とメソッド(メッセージとオブジェクト状態を引数に取る手続き)の集合を含むレコードにすぎない


Presentation
=======================

[gnab/remark](https://github.com/gnab/remark) を利用
