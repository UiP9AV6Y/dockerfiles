
[microbadger]: https://microbadger.com/images/uip9av6y/confgit
[docker library]: https://store.docker.com/images/alpine
[LGPL-2.1]: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.txt
[vendor homepage]: https://git-scm.com/
[**--branch**]:  https://www.git-scm.com/docs/git-clone#git-clone--bltnamegt
[ssh options]: https://man.openbsd.org/ssh_config
[depth]: https://www.git-scm.com/docs/git-clone#git-clone---depthltdepthgt

[![](https://images.microbadger.com/badges/image/uip9av6y/confgit.svg)][microbadger]
[![](https://images.microbadger.com/badges/version/uip9av6y/confgit.svg)][microbadger]
[![](https://images.microbadger.com/badges/commit/uip9av6y/confgit.svg)][microbadger]

# how to use this image

the sole purpose of this image is to retrieve a remote Git
repository and optionally execute a post-retrieval hook.
instructions are either provided via environment variables or
the commandline.

the only strategy currently supported is `clone`. in order to
reduce network traffic and disk space, the operation is performed
with a [depth][] of 1.

the *examples/* directory contains a suggested deployment setup
using docker-compose.

## with instructions via commandline

`confgit [-s SHA1|-t TAG|-b BRANCH] URL [DIR] [GIT_ARG]...`

The *URL* parameter specifies the upstream Git repository to
retrieve. It is mandatory unless the **CONFGIT_URL**
environment variable is provided as well. *DIR* contains a
local file path which will hold the repository content; it
must not necessarily exist beforehand and will default to
the current working directory, unless **CONFGIT_DIRECTORY**
is defined.
The latest version of the default branch is retrieved if no
other instructions are provided. All other parameters are
passed on to `git` unaltered.

to get more information about the supported commandlines,
run the image with the *-?* option

`docker run --rm -it --name my-confgit
  confgit:latest
  -?`

## with instructions via enviroment variables

* *CONFGIT_IDENTITY*

  Private SSH key value used for SSH connections only.
* *CONFGIT_IDENTITY_FILE*

  Path to a (mounted) file containing the ssh key (see
  CONFGIT_IDENTITY).
* *CONFGIT_IDENTITY_SECRET*

  Docker secret containing the ssh key (see CONFGIT_IDENTITY).
* *CONFGIT_PASSWORD*

  Authentication secret. This value will be used for HTTP
  Basic Auth (http:// or https://) only. For SSH connections
  refer to CONFGIT_IDENTITY.
* *CONFGIT_PASSWORD_FILE*

  Path to a (mounted) file containing the password (see
  CONFGIT_PASSWORD).
* *CONFGIT_PASSWORD_SECRET*

  Docker secret containing the password (see CONFGIT_SECRET).
* *CONFGIT_USERNAME*

  Authentication ident. This value will be used for both HTTP
  Basic Auth (http:// or https://) as well as authentication
  via SSH (ssh://).
* *CONFGIT_USERNAME_FILE*

  Path to a (mounted) file containing the username (see
  CONFGIT_USERNAME).
* *CONFGIT_USERNAME_SECRET*

  Docker secret containing the username (see CONFGIT_USERNAME).
* *CONFGIT_URL*

  Remote Git repository to retrieve.
* *CONFGIT_BRANCH*

  Git branch to retrieve.
* *CONFGIT_SHA*

  Git commit to retrieve
* *CONFGIT_TAG*

  Git tag to fetch
* *CONFGIT_DIRECTORY*

  Local directory to place the repository content. Defaults
  to the current working directory.
* *CONFGIT_SUBMODULES*

  Git submodules are only initialized if this variable is
  defined.
* *CONFGIT_NO_HOOK*

  Omit the execution of the *confgit* hook from the
  repository.
  This is intended for scenarios where the upstream source
  cannot be trusted or its logic does not need to apply to
  the current context.
* *CONFGIT_SSH_OPTIONS*

  List of [ssh options][] separated by a space. The key/value
  separator is =. (e.g. **IdentitiesOnly=yes
  PasswordAuthentication=no**)

In its simplest form, the image can be used to clone an
application configuration from the repository main branch.

`docker run -d --name my-running-confgit
  -v /etc/application
  --env CONFGIT_URL=http://repo.example.com/conf/application.git
  --env CONFGIT_DIRECTORY=/etc/application
  confgit:latest`

the volume (**/etc/application**) can then be mounted in other
containers.

# image setup

the image is based on the **alpine** image from
the [docker library][].

# license

the software contained in this image is licensed under the
[LGPL-2.1][]. additional information can be found on the
[vendor homepage][].

as with all Docker images, these likely also contain other
software which may be under other licenses (such as Bash, etc
from the base distribution, along with any direct or indirect
dependencies of the primary software being contained).
it is the image user's responsibility to ensure that any use of
this image complies with any relevant licenses for all software
contained within.