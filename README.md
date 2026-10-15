# paperman.jp

<b>公式サイトだったドメインに設置されている非公式のファンサイト</b>です。

ペーパーマンの公式サイトのドメインが期限切れになってしまったため、
回収して非公式のファンサイトとしてお預かりしています。

## 運用ドメイン

* [paperman.jp](https://paperman.jp/)
  * [updater用](https://paperman.jp/patch_inf/index_gp.aspx)
  * [404ページ](https://paperman.jp/404.aspx)
  * [403ページ](https://paperman.jp/403.aspx) ※404に向けています。

## DNS転送設定例

ドメインを対象のサーバーに転送する設定など

```
a * {ここにサーバーのIP、{}の括弧はとること。}
```
* XREAではAAAAレコードは使用しません。
* IPv6のサーバアドレスが利用可能な場合、AAAAレコードも追加してください。

## 運用サーバ

* apache2前提の構成です。
  * nginxの場合は適切に変更をしてください。
* aspxファイルをhtmlとして扱うようにし、従来と同じファイルになるようにしています。
* ローカルでビルドして反映してください。
  * これはXREA上でビルドをしたくないからです。異なる環境の場合はサーバ上でビルド可能です。
* デプロイ時は、 DocumentRoot に相当するディレクトリにリポジトリを直置きしないでください
  * 不必要なファイルの閲覧やスクリプトを実行されるリスクがあります。
* ```src/public``` ディレクトリをWEBサーバの DocumentRoot としてください。
  * ```public```下が公開用のファイルです。
  * DocumentRoot が既に指定されている場合は別ディレクトリに設置してください
  * 別ディレクトリとした場合はシンボリックリンクを張るか、コピーしてください（後述

### シンボリックリンクの張り方の例

{}の中括弧は取り除くこと。

```ln -s {src/publicディレクトリのパス} {シンボリックリンク名}```

### XREAで運用する場合
```miscellaneous\script\xrea``` 下に、 xrea用の構成スクリプトを用意してあります。<br>
全て使う必要はないので、中身を確認の上で実行してください。<br>
また、```public_html```下に設置したシンボリックリンクは、<br>
サーバーの再起動などでディレクトリに置き換えられてしまうことがあります。<br>
```cron```などを利用して自働復旧を構成することを推奨します。<br>

## リリース手順
* リリースの前にリポジトリでタグを切ってください(github上で実施して構いません)<br>
* リリースを行うサーバーで ```git fetch```<br>
* リリースを行うサーバーで ```git tag --sort=version:refname``` でタグを確認<br>
* リリースを行うサーバーで ```git checkout refs/tags/{tagName}```<br>

※ 巻き戻す時は対象のリリースタグをチェックアウトしてください<br>
※ データベースなどを持たないのでマイグレーションなどの考慮は不要です<br>

## 開発ツール等
### npm
NPM で webpack.js を構成し、minify を行っています。
これによりファイルサイズを小さくしています。
ローカルPC（ホスト機）でもnode.jsとnpmを用意すればビルドなどができますが、
コンテナ上で行うことを推奨します。

### bootstrap5
https://getbootstrap.jp/<br>
ページの整形に使用しています。<br>
```scss```で結合して```app.css```を通じて使えるようしています。

### fontawesome
https://fontawesome.com<br>
特殊な記号の表示で使用しています。<br>
```webpack.js```内で構成しており、フォントそのものの展開とscssのビルドが必要です。<br>
リンクアイコンの記号で```<i class="fas fa-angle-right"></i>```などの形で使用しており、
ページ内を```fa```で検索すれば使用箇所を見つけられるはずです。

### git
https://github.com/kamigayatsuri/paperman.jp
* 誤って履歴に残したくないファイルをコミットしてしまった場合、次のようにすること。
  * ```git stash``` などで差分がない状態にする。
  * ```git filter-branch --tree-filter "rm -f {対象ファイルパス}" HEAD``` あるいは
  * ```git filter-branch --tree-filter "rm -f -r {対象ディレクトリパス} " HEAD```
  * ```git gc --aggressive --prune=now```

## ローカル環境構築
Dockerでコンテナを動作させるための環境構築が必要です。
MacやWindowsなら[Docker Desktop](https://www.docker.com/products/docker-desktop/)<br/>
その他のLinux環境でもDockerを入手してインストールしてください。

インストールしたら、<br>
ローカル用サーバ構築に必要な設定ファイルを<br>
```
docker/localhost/
```
に置いてあるのでビルドしていきます。<br>
また、```docker/localhost/tools/``` 下にWindows用のバッチと<br>その他用のシェルスクリプトを置いています。

### Windowsの場合

```docker/localhost/tools/bat/up.bat```を実行するか、<br>
コマンドプロンプトを上記のディレクトリで起動して<br>
```docker compose up -d```してください。

(Windowsのエクスプローラのアドレスバーで```cmd```)

### その他の環境
```docker/localhost/tools/bat/up.sh```を実行するか、<br>
その他の環境では、```cd```コマンドで該当ディレクトリに移動し、<br>
```docker compose up -d```してください。

## 開発中のビルド実行

コンテナ上で ```npm run dev``` を実行してください。<br>
```npm run prod```にするとリリース用のビルドを行います。<br>
バッチかシェルスクリプトの実行で行うこともできます。<br>
NPMの更新をする場合は ```npm update``` や ```npm audit fix```などを適時で実施してください。

また、下記を```webpack.js```によりビルド時に自動更新しています。
* css, js, imageなどのキャッシュ対策のGETパラメータ
  * ```__BUILD_VERSION__```の文字列が、ビルド時に自動的にバージョンで置き換えられます。
  * 本家の開発開始が発表された2004-05を基準とし、日は不明のため01日からy.m.dとしています。
* ```.htaccess``` の ```Header set Last-Modified```
  * ```src/resources/.htaccess.tpl```の```__BUILD_TIME__```を置換して再配置しています。
  * ```IMF-fixdate```形式です
* ```openGraph```(```og```)の```og:update_time```
  * 各HTML中の```__OG_UPDATE_TIME__```を置換して配置しています。
  * ```ISO 8601```形式です。
* ```<header>~</header>``` 内のコメント部分

## SNS投稿時のカード機能について
### X (旧Twitter)
* 下記で検証すること。<br>
  ~~https://cards-dev.twitter.com/validator~~
* バリデータは下記の記載されているように廃止されました。<br>
  https://devcommunity.x.com/t/card-validator-preview-removal/175006<br>
  このため、実際に投稿に記述を確認する必要があります。

### Facebook
* 下記で反映内容の確認を行ってください。<br>
  https://developers.facebook.com/tools/debug/