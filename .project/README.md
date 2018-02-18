# docker cloud builds

the environment for builds in the public docker cloud differs
from the [documentation][].

the following values match their usage/description from the
[documentation][]:

* DOCKER_REPO
* SOURCE_BRANCH
* COMMIT_MSG
* IMAGE_NAME

the following values exist on top of the documented on
(excluded are values common to POSIX shells like, HOME, PWD, USER ,...):

* DOCKER_HOST

  socket for DinD scenarios

* PYTHONUNBUFFERED

  has value *1*

* PUSH

  has value *true*

* GIT_SHA1

  git commit hash

* BUILD_PATH

  absolute path with the name of the built image (e.g. **/example**)

* SIGNED_URLS

  JSON string

* DOCKER_TAG

  image tag of the image currently built

* GIT_MSG

  same as **COMMIT_MSG**

* BUILD_CODE

  random string

* DOCKERCFG

  JSON string containing docker hub registry authentication
  information

* DOCKERFILE_PATH

  ??? (was empty when observed)

* SOURCE_TYPE

  name of the VCS in use (e.g. *git*)

* MAX_LOG_SIZE

  size in bytes for log buffer (???)

the following environment variable deviate from their
documented nature:

* CACHE_TAG

  docker image tag from the previous build cycle. will be
  an empty string for the first build.

[documentation]: https://docs.docker.com/docker-cloud/builds/advanced/