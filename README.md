[![CircleCI](https://circleci.com/gh/thape-cn/oauth2id.svg?style=svg)](https://circleci.com/gh/thape-cn/oauth2id) [![Docker Images](https://img.shields.io/badge/Docker%20Images-blue.svg)](https://hub.docker.com/r/ericguo/oauth2id/tags)

# Oauth2id

SSO Portal based on oauth2 id protocol


# Quickly Start

```bash
cp config/database.yml.sample config/database.yml
rm config/credentials.yml.enc # or ask for master.key
export EDITOR=vim
bin/rails credentials:edit # paste credentials.yml.sample or skip
bin/rails test:all
```

# Build & Run in docker mode

```bash
docker build --tag ericguo/oauth2id:main-$(uname -m) .
docker run -p 3000:3000 -d --restart always --name oauth2id --env RAILS_MASTER_KEY=YourMasterKey -v ./storage:/rails/storage ericguo/oauth2id:main-$(uname -m)
# If can not start in above, do the debug.
docker run --env RAILS_MASTER_KEY=YourMasterKey -v ./storage:/rails/storage -it ericguo/oauth2id:main-arm64 bash
# After success, push manually.
docker push ericguo/oauth2id:main-$(uname -m)
```

# First user is admin

The first user will automatically become the admin, please ignore 500 erros as jwt token at first sign-in not via login screen.

# Dev env setup

Setup the puma-dev to support https in local.

```
brew install puma/puma/puma-dev
sudo puma-dev -setup
puma-dev -install
cd ~/.puma-dev
ln -s /Users/<username>/git/oauth2id oauth2id
```

Then visit the `https://oauth2id.test` and accept the invalid https certificate, for higher version MacOS, need opening Keychain Access and moving the Puma-dev CA certificate into the System column under keychains then restarting the browser, [it's a known issue](https://github.com/puma/puma-dev/issues/84#issuecomment-252339375)

In order to make sure Faraday running in local also works well in https, we also need to add Puma-dev CA in OpenSSL library trust list as well, the OpenSSL CA is by default at `/usr/local/etc/openssl/cert.pem`, since we already have valid MacOS Pumda-dev CA in system, we can use [openssl-osx-ca](https://github.com/raggi/openssl-osx-ca) to regenerate the `cert.pem` file so just installs and regenerate `cert.pem` file.

In order to make [httpclient](https://github.com/nahi/httpclient/issues/335) also works well in https, need copy generated cert.pem to httpclient folder. There is two `pem` files in httpclient currently, but Puma-dev CA is 1024, so safe to overwrite.

```bash
# or /usr/local/etc/openssl@1.1/cert.pem depend on versions
cp /usr/local/etc/openssl/cert.pem /usr/local/lib/ruby/gems/3.0.0/gems/httpclient-2.8.3/lib/httpclient/cacert.pem
```

For Monterey running Apple Silicon on Ruby 3.2

```bash
cp /opt/homebrew/etc/openssl\@1.1/cert.pem /opt/homebrew/lib/ruby/gems/3.2.0/gems/httpclient-2.8.3/lib/httpclient/cacert.pem
cp /opt/homebrew/etc/openssl\@1.1/cert.pem /opt/homebrew/etc/ca-certificates/cert.pem
```

# Generate signing key

## Open ID Connect

Just following [doorkeeper-openid_connect gem readme](https://github.com/doorkeeper-gem/doorkeeper-openid_connect#configuration):

```bash
openssl genpkey -algorithm RSA -out oauth2id_oidc_private_key.pem -pkeyopt rsa_keygen_bits:2048
openssl rsa -pubout -in oauth2id_oidc_private_key.pem -out oauth2id_oidc_public_key.pem
```

Notice replace oauth2id with your new site name, notice you can get public key from [/oauth/discovery/keys](https://oauth2id.dev/oauth/discovery/keys) as well.


## SAML 2.0

```bash
openssl req -x509 -sha256 -nodes -days 3650 -newkey rsa:2048 -keyout oauth2id_saml_key.key -out oauth2id_saml_cert.crt
# Show SHA1 Fingerprint
openssl x509 -in oauth2id_saml_cert.crt -noout -sha256 -fingerprint
```

## Generate RS256 for asymmetric JWT

```bash
openssl genpkey -algorithm RSA -out oauth2id_jwt_private_key.pem -pkeyopt rsa_keygen_bits:2048
openssl rsa -pubout -in oauth2id_jwt_private_key.pem -out oauth2id_jwt_public_key.pem
```

# Generate initial data


```bash
bin/setup
```


## To migrate MySQL to Postgresql

Get db_converter.py from below:

https://github.com/bhmj/mysql-postgresql-converter

```bash
mysqldump --set-gtid-purged=OFF --no-tablespaces --compatible=postgresql --default-character-set=utf8 -r databasename.mysql -u thape_sso_prod thape_sso_prod -p
python ./mysql-postgresql-converter/db_converter.py databasename.mysql databasename.psql
zip -9 databasename.zip databasename.psql
```

Copy the databasename.psql and import via below.

```bat
psql -d postgres
```

```psql
DROP DATABASE thape_sso_dev;
CREATE DATABASE thape_sso_dev WITH ENCODING='UTF8' OWNER='guochunzhong';
\q
```

```bat
psql -d thape_sso_dev -f databasename.psql
```

May replace ' datetime(6) ' with ' timestamp(6) without time zone '.

## Notes to using thape production data

Need running below to make production sign-in success.

```ruby
u=User.find 4431 # it's me
u.confirm
```
