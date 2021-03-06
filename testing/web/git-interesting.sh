#!/bin/sh

usage() {
    cat >> /dev/stderr <<EOF

Usage:

    $0 <gitrev> [ <repodir> ]

Where <repodir> defaults to the current directory.  XXX: The parameter
order needs to be reversed.

Examine <gitrev> in <repodir> and determine if it is sufficiently
"interesting" to be worth testing.

"interesting" is any of:

    - a commit with a tag

    - a merge point

    [- a branch point (disabled)]

    - a commit that changes build and/or source files

EOF
}

if test $# -lt 1; then
    usage
    exit 1
fi

set -eu

webdir=$(cd $(dirname $0) && pwd)
gitrev=$1 ; shift
if test $# -gt 0 ; then
    cd $1
    shift
fi

# All tags are interesting.
#
# If there is no tag then this command fails with an error so suppress
# that.

tag=$(git describe --exact-match ${gitrev} 2>/dev/null || :)
if test -n "${tag}" ; then
    echo tag: ${tag}
    exit 0
fi

# All merges (commits with more than one parent) are "interesting".

parents=$(git show --no-patch --format=%P "${gitrev}^{commit}")
if test $(echo ${parents} | wc -w) -gt 1 ; then
    echo merge: ${parents}
    exit 0
fi

# All branches (commits with more than one child) are "interesting".
#
# Determining children is messy for some reason.  Search revisions
# more recent than GITREV (REV.. seems to be interpreted as that) for
# a parent matching GITREV.
#
# For the moment don't consider them interesting as the branch points
# tend to be weird.

if false ; then
    children=$(git rev-list --parents ${gitrev}.. | \
		   while read commit parents ; do
		       case " ${parents} " in
			   *" ${gitrev}"* ) echo ${commit} ;;
		       esac
		   done)
    if test $(echo ${children} | wc -w) -gt 1 ; then
	echo branch: ${children}
	exit 0
    fi
fi

# grep . exits non-zero when there is no input (i.e., the diff is
# empty); and this will cause the command to fail.

if git show "${gitrev}^{commit}" \
       Makefile \
       Makefile.inc \
       lib \
       mk \
       programs \
       include \
       linux \
       testing/pluto \
       testing/sanitizers \
       testing/baseconfigs \
	| grep . > /dev/null ; then
    echo "true"
    exit 0
fi

exit 1
