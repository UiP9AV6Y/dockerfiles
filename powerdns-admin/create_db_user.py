#!/usr/bin/env python

from app.models import User
import os, random, string

def bootstrap():
    generated = ''.join([random.choice(string.ascii_letters + string.digits) for n in xrange(16)])
    username = os.environ.get('POWERDNS_ADMIN_USERNAME', 'admin')
    password = os.environ.get('POWERDNS_ADMIN_PASSWORD', generated)
    email = os.environ.get('POWERDNS_ADMIN_EMAIL', 'root@localhost')

    user = User(username=username, plain_text_password=password)
    result = user.create_local_user()

    if True == result:
        print('user {} has been created with password {}'.format(username, password))
    else:
        print(result)

if __name__ == '__main__':
    bootstrap()