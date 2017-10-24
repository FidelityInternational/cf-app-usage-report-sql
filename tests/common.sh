#!/bin/bash

# based on https://github.com/concourse/git-resource/blob/master/test/helpers.sh#L19
run() {

	RED='\e[0;31m'
	LRED='\e[1;31m'
	GREEN='\e[0;32m'
	NC='\e[0m' # No Color
	export TEMPDIR=$(mktemp -d ${TEMPDIR_ROOT}/tests.XXXXXX)

	echo -e 'running \e[33m'"$@"$'\e[0m...'

  set +e
	output="$(eval "set -e -u -o pipefail; _before_each && $@ && _after_each" 2>&1 | sed -e 's/^/  /g')"
	RET=$?
	set -e

	if [ $RET != 0 ]; then
		echo -e "${RED}${output}\n${NC}"
		echo -e "${LRED}TEST $@ FAILED${NC}"
	else
		echo -e "${GREEN}Test $@ OK.${NC}"
	fi
	echo ""
	return $RET
}
