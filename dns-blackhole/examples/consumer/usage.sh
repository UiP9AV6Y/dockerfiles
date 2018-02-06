#!/bin/sh -eu

echo "##"

echo example.com
echo "not blocked"
dig @nameserver example.com +short

echo "##"

echo stackoverflow.com
echo "not blocked due to whitelist entry"
dig @nameserver stackoverflow.com +short

echo "##"

echo docker.com
echo "blocked via hosts file from upstream provider"
dig @nameserver docker.com +short

echo "##"

echo google.com
echo "blocked via blacklist"
dig @nameserver google.com +short

echo "##"
