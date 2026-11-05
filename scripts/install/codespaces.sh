#!/bin/bash

#################################################################
#								#
# Copyright (c) 2021 EFUZY LLC 
# (not registered yet wink wink see efuzy.com registrars history TY AWS) 
# and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# 
# 
# to do inject the following into ~/.bashrc
# source $(pkg-config --variable=prefix yottadb)/ydb_env_set
# export ydb_routines=`$ydb_dist/yottadb -run %XCMD 'W $P($P($ZRO,"(",1,2),")")_" "_"/home/aa/work/mumps.io/routines"_")"_$P($ZRO,")",2,$L($ZRO,")"))'` 
# 
#
set -e
 
 cd /workspaces/mumps.io

 wget https://download.yottadb.com/ydbinstall.sh && chmod +x ydbinstall.sh
 # delete anything you can and rerun below with --overwrite-existing if you need to reinstall and blah blah
 ./ydbinstall.sh
