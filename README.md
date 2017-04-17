# Mastodon memo

## アクセストークンの取得

* [cumentation/Testing-with-cURL.md at master · tootsuite/documentatio](https://github.com/tootsuite/documentation/blob/master/Using-the-API/Testing-with-cURL.md)

```
$ curl -X POST -sS https://inari.opencocon.org/api/v1/apps -F "client_name=PerlBot" -F "redirect_uris=urn:ietf:wg:oauth:2.0:oob" -F "scopes=read write follow" | jq .
{
  "id": 7,
  "redirect_uri": "urn:ietf:wg:oauth:2.0:oob",
  "client_id": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "client_secret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
}
$ curl -X POST -sS https://inari.opencocon.org/oauth/token -d "client_id=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx&client_secret=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx&grant_type=password&username=matoken@example.org&password=MASTODONPASSWORD&scope=read%20write%20follow" | jq .
{
  "access_token": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "token_type": "bearer",
  "scope": "read write follow",
  "created_at": 1492338622
}
```

※この方法では二段階認証が有効だと失敗する．一旦二段階認証を無効にしてアクセストークンを取得，その後二段階認証有効にしてもアクセストークンは利用できた．

## follow list取得

> Getting who account is following:
GET /api/v1/accounts/:id/following

crontabで一日一回書き出す例．
自分のインスタンス分はインスタンス名がつかないのでawkで整形している．

```
8 3 * * *       curl -X GET -sS https://inari.opencocon.org/api/v1/accounts/3/following -d "client_id=&client_secret=&access_token=TOKEN" | jq -r .[].acct | awk '!match($0, /@/){print $0"@inari.opencocon.org"} match($0,/@/){print $0}' > ~/ownCloud/Documents/mastodon/matoken@inari.opencocon.org.csv
```

## ストリーミングAPI

とりあえず閲覧は出来るが流れが遅いとバッファーに溜まって遅延する．
xxxx部分はaccess_token

```
$ curl --header "Authorization: Bearer xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" -s https://inari.opencocon.org/api/v1/streaming/public | grep ^data: | sed -e 's/^.*: //' | jq -r .account.display_name,.account.acct,.content | xargs -n1 echo | lynx -stdin -dump
```

## Perl module

```
$ cpanm Mastodon
```

### Perlで文字投稿

* toot.pl


### ストリーミングをgolでpopup表示

* streaming.pl
