
[microbadger]: https://microbadger.com/images/uip9av6y/powerdns-admin
[docker library]: https://store.docker.com/images/alpine
[MIT]: https://github.com/thomasDOTde/PowerDNS-Admin/blob/master/LICENSE
[vendor homepage]: https://github.com/thomasDOTde/PowerDNS-Admin/
[PowerDNS]: https://www.powerdns.com/
[webserver]: https://uwsgi-docs.readthedocs.io/en/latest/WebServers.html
[uWSGI]: https://uwsgi-docs.readthedocs.io/

[![](https://images.microbadger.com/badges/image/uip9av6y/powerdns-admin.svg)][microbadger]
[![](https://images.microbadger.com/badges/version/uip9av6y/powerdns-admin.svg)][microbadger]
[![](https://images.microbadger.com/badges/commit/uip9av6y/powerdns-admin.svg)][microbadger]

# how to use this image

PowerDNS-Admin is a web GUI for [PowerDNS][] built on Flask.

this docker image runs the application using [uWSGI][]. it
comes in various flavours, each tailored to be used with a
specific database backend.

| Docker Tag | Database Backend |
| ---------- | ---------------- |
| odbc | Oracle Database Connection |
| mssql | MSSQL using the FreeTDS driver |
| mysql | Mysql/MariaDb/Percona databases |
| pgsql | Postgres using the *psycopg2* adapter |
| sqlite3 | uses the Python default sqlite adapter |

`docker run -d --name my-running-powerdns-admin
  --env POWERDNS_ADMIN_DB_URI='postgresql://pdnsa:pdnsa@postgres:5432/pdnsa'
  --env POWERDNS_ADMIN_API_URL='http://pdns:8081/'
  --env POWERDNS_ADMIN_API_KEY='secret_key'
  --env POWERDNS_ADMIN_USERNAME=admin
  --env POWERDNS_ADMIN_PASSWORD=admin
  powerdns-admin:latest`

the *examples/* directory contains a simple deployment setup
using docker-compose.

## environment variables

* *UWSGI_BASE_URI*

  root URI which is served by uWSGI. the default is **/**.
  setting a different value allows the upstream web server
  to serve multiple applications from the same domain/port.
* *UWSGI_PROTOCOL*

  communication protocol with upstream [webserver][].

  the default value is *http*
* *POWERDNS_ADMIN_CONF*

  path to the application configuration file. default value:
  */app/config.py*
* *POWERDNS_ADMIN_USERNAME*

  authentication identifier of the local administrator
  account. if this variable is defined, a local user account
  is created if not already existing. PowerDNS-Admin promotes
  the first authenticated user to the role of an
  administrator. if no authentication systems are enabled,
  this option provides a convenient way to create a user
  without further interaction.
* *POWERDNS_ADMIN_PASSWORD*
  plaintext password for the administrator account
  (see **POWERDNS_ADMIN_USERNAME**)

  default value: random generated value

  **NOTE**: the password is emitted on stdout upon creation,
  regardless if one was provided or generated.
* *POWERDNS_ADMIN_EMAIL*
  email address for the administrator account
  (see **POWERDNS_ADMIN_USERNAME**)

  default value: *root@localhost*
* *POWERDNS_ADMIN_TIMEOUT*

  value for **TIMEOUT** (default: 10)
* *POWERDNS_ADMIN_LOGIN_TITLE*

  value for **TIMEOUT** (default: empty string)
* *POWERDNS_ADMIN_LOG_LEVEL*

  value for **LOG_LEVEL** (default: *WARNING*)

* *POWERDNS_ADMIN_BASIC_AUTH*

  accept credentials via HTTP header.

* *POWERDNS_ADMIN_SIGNUP*

  signups are disabled unless this variable is defined.

* *POWERDNS_ADMIN_PRETTY_IPV6_PTR*

  if defined, IPv6 PTR records are rendered in a more
  readable format

* *POWERDNS_ADMIN_SECRET_KEY*

  secret key for token generation. if not defined, a random
  value is generated.

* *POWERDNS_ADMIN_RECORDS_ALLOW_EDIT*, *POWERDNS_ADMIN_FORWARD_RECORDS_ALLOW_EDIT*, *POWERDNS_ADMIN_REVERSE_RECORDS_ALLOW_EDIT*

  record type which can be edited. the default values for
  each variable are: SOA A AAAA CAA CNAME MX PTR SPF SRV TXT LOC NS PTR
* *POWERDNS_ADMIN_DB_URI*

  SQLalchemy URI for the database connection
* *POWERDNS_ADMIN_API_URL*

  URL base to the PowerDNS API endpoint

  **NOTE**: this values does not include the */servers/localhost* part, nor the API version.
* *POWERDNS_ADMIN_API_KEY*

  API authentication token
* *POWERDNS_ADMIN_API_LEGACY*

  define this variable, if the remote PowerDNS server is
  less than version 4.0.0
* *POWERDNS_ADMIN_SAML_ENABLED*

  enable SAML authentication backend
*  *POWERDNS_ADMIN_SAML_METADATA_URL*,
  *POWERDNS_ADMIN_SAML_METADATA_CACHE_LIFETIME*,
  *POWERDNS_ADMIN_SAML_SP_ENTITY_ID*,
  *POWERDNS_ADMIN_SAML_SP_CONTACT_NAME*,
  *POWERDNS_ADMIN_SAML_SP_CONTACT_MAIL*

  maps to their respective PowerDNS-Admin config values.
* *POWERDNS_ADMIN_SAML_DEBUG*,
  *POWERDNS_ADMIN_SAML_LOGOUT*,
  *POWERDNS_ADMIN_SAML_SIGN_REQUEST*

  if defined, the respective SAML feature will be enabled,
  otherwise it will remain disabled.
* *POWERDNS_ADMIN_GOOGLE_ENABLED*

  enable Google oAuth authentication backend
* *POWERDNS_ADMIN_GOOGLE_SCOPE*,
  *POWERDNS_ADMIN_GOOGLE_API_URL*,
  *POWERDNS_ADMIN_GOOGLE_TOKEN_URL*,
  *POWERDNS_ADMIN_GOOGLE_AUTH_URL*,
  *POWERDNS_ADMIN_GOOGLE_REDIRECT_URI*,
  *POWERDNS_ADMIN_GOOGLE_KEY*,
  *POWERDNS_ADMIN_GOOGLE_SECRET*

  maps to their respective PowerDNS-Admin config values.
* *POWERDNS_ADMIN_GITHUB_ENABLED*

  enable Github oAuth authentication backend
* *POWERDNS_ADMIN_GITHUB_SCOPE*,
  *POWERDNS_ADMIN_GITHUB_API_URL*,
  *POWERDNS_ADMIN_GITHUB_TOKEN_URL*,
  *POWERDNS_ADMIN_GITHUB_AUTH_URL*,
  *POWERDNS_ADMIN_GITHUB_KEY*,
  *POWERDNS_ADMIN_GITHUB_SECRET*

  maps to their respective PowerDNS-Admin config values.
* *POWERDNS_ADMIN_LDAP_ENABLED*

  enable LDAP authentication backend
* *POWERDNS_ADMIN_LDAP_TYPE*,
  *POWERDNS_ADMIN_LDAP_URI*,
  *POWERDNS_ADMIN_LDAP_BIND_DN*,
  *POWERDNS_ADMIN_LDAP_BIND_PW*,
  *POWERDNS_ADMIN_LDAP_USERNAME_FIELD*,
  *POWERDNS_ADMIN_LDAP_FILTER*,
  *POWERDNS_ADMIN_LDAP_SEARCH_BASE*,
  *POWERDNS_ADMIN_LDAP_ADMIN_GROUP*,
  *POWERDNS_ADMIN_LDAP_USER_GROUP*

  maps to their respective PowerDNS-Admin config values.
* *POWERDNS_ADMIN_LDAP_GROUP_SECURITY*

  if defined, the respective LDAP feature will be enabled,
  otherwise it will remain disabled.

# volumes

| path | usage |
| ---- | ----- |
| /app/migrations | output directory for SQLalchemy migration data |
| /app/uploads | storage directory for uploads (e.g. avatar images) |
| /app/saml | SAML configuration |

# ports

| port | usage |
| ---- | ----- |
| 9191 | uWSGI statistics endpoint |
| 9393 | uWSGI application socket |

# image setup

the image is based on the **alpine** image from
the [docker library][].

# license

the software contained in this image is licensed under the
[MIT][]. additional information can be found on the
[vendor homepage][].

as with all Docker images, these likely also contain other
software which may be under other licenses (such as Bash, etc
from the base distribution, along with any direct or indirect
dependencies of the primary software being contained).
it is the image user's responsibility to ensure that any use of
this image complies with any relevant licenses for all software
contained within.