#!/usr/bin/env bash

sudo -i su root
apt-get update && apt-get upgrade
apt-get install --no-install-recommends file cmake make gawk gcc git curl tcsh libjansson4 {libconfig,libelf,libicu,libncurses,libreadline,libjansson,libssl}-dev binutils ca-certificates

mkdir /tmp/tmp && cd /tmp/tmp && wget https://download.yottadb.com/ydbinstall.sh && chmod +x ydbinstall.sh
./ydbinstall.sh --verbose

source $(pkg-config --variable=prefix yottadb)/ydb_env_set
export ydb_routines=`$ydb_dist/yottadb -run %XCMD 'W $P($P($ZRO,"(",1,2),")")_" "_"/workspaces/mumps.io/routines"_")"_$P($ZRO,")",2,$L($ZRO,")"))'`   
       #cp -a backend/routines/*.m "$ydb_dir/r/"
       # Run tests (quiet on success). Fail CI if we see FAIL/ERR or YDB errors.
       # OUT="$(mktemp)"
# set +e
# yottadb -direct <<'EOF' >"$OUT" 2>&1
# ZL "MIOTESTS.m"
# D ^MIOTESTS
# HALT
# EOF
# RC=$?
# set -e

# cat "$OUT"

echo "\n\nMUMPS.IO INSTALLED SUCCESSFULLY \n\n\t\t\t GITHUB.COM/AA-87 (ahmedatefuzy@gmail.com")"
