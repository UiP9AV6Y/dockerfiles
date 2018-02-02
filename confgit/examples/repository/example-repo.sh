#!/bin/sh -eu
#
# this script bootstraps the environment for the example
# environment. it creates a local git repository with two
# branches; one containing the NGINX server configuration
# (config), the other one the content to be served by the
# NGINX container (content). both branches contain a
# configit setup hook to be executed once the repository
# has been cloned.
# in a productive environment, the config and content
# would be hosted in two separate repositories, but for
# demonstration purposes, a single repository is used here.
#

ORIGIN_REPO="$1"
LOCAL_REPO=$(mktemp -d)
CHECKPOINT="$PWD"

git clone \
  "$ORIGIN_REPO" \
  "$LOCAL_REPO"

cd "$LOCAL_REPO"

#
# MASTER
#

cat <<"EOF" > README.md
this is an example repository.

the *content* branch contains the document root to be served.
the *config* branch contains the NGINX configuration.
EOF
git add README.md
git commit -m 'Initial commit'
git push -u origin master

#
# CONTENT
#

git checkout -b content master
mkdir .confgit
cat <<"EOF" > .confgit/setup
#!/bin/sh
set -eux

echo $0
EOF
chmod +x .confgit/setup
mkdir public
cat <<"EOF" > public/index.html
<h1>example.com</h1>
EOF
git add .confgit public
git commit -m 'Initial website implementation'
git push -u origin content

#
# CONFIG
#

git checkout -b config master
mkdir .confgit
cat <<"EOF" > .confgit/setup
#!/bin/sh
set -eux

sed \
  -e "s|@DOMAIN@|${NGINX_HOST}|g" \
  -e "s|@PORT@|${NGINX_PORT}|g" \
  default.conf.tpl > default.conf
EOF
chmod +x .confgit/setup
cat <<"EOF" > default.conf.tpl
server {
  listen       @PORT@;
  server_name  @DOMAIN@;

  location / {
    root   /usr/share/nginx/public;
    index  index.html index.htm;
  }
}
EOF

git add .confgit default.conf.tpl
git commit -m 'Initial server configuration'
git push -u origin config

cd "$CHECKPOINT"
rm -rf "$LOCAL_REPO"