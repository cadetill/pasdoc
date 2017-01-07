#!/bin/bash
set -eu

# $1 is your username on sourceforge,
# $2 is directory on sourcefore (usually you will start this with
# /home/project-web/pasdoc/...).
#
# This script logs to sourceforge using given username
# (you will be asked for password unless you set up ssh keys)
# and executes
#   chgrp -R pasdoc *
#   chmod -R g+w *
# This means that every file in given directory is made writeable
# by pasdoc group, which means pasdoc developers.
#
# Later note: chgrp -R pasdoc is not supported on SF anymore.
# Group is always "apache", and for security I would not like to have
# files writeable by apache on a shared host.

echo 'ssh_chmod_writeable_by_pasdoc: Not changing permissions, as it is no longer possible on SourceForge.'

# SF_USERNAME="$1"
# SF_PATH="$2"
# shift 2

# ssh -l "$SF_USERNAME" shell.sourceforge.net <<EOF
#   cd "$SF_PATH"
#   chgrp -R pasdoc *
#   chmod -R g+w *
# EOF
