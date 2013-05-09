#####################################################################
# 
# This file is part of bash.utils.
# 
# bash.utils is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# bash.utils is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with bash.utils.  If not, see <http://www.gnu.org/licenses/>.
# 
# Copyright 2012 Wayne Vosberg <wayne.vosberg@mindtunnel.com>
#
#####################################################################
#
# A collection of bash functions I've created to simplify my life.
#
# Use at your own risk! No guarantee of any type is implied by making
# this file public.  But if you like it, feel free to send a few US$
# via PayPal to wayne.vosberg@gmail.com
#
#####################################################################
#
# to use these functions, source this file into your own bash script
# (note, the included makefile will put this into ~/lib
#
# . ~/lib/bash.utils/utils.sh
#
#####################################################################
# abort "error message"
#
# This may be called in cases where a command failure is unrecoverable
# and the program must exit. The function will write out a custom error
# message along with the return of the last command (the one that failed).
#
# usage:
#
# rm /tmp || abort "/tmp is a directory!"
#
function abort
{
  local E=$?
  echo "ERROR ${E}: $1"
  exit ${E}
}


#####################################################################
# startLog "<log file name>"
#
# Start logging stdout to a log file as well as the terminal.
# The current stdout is saved as FD 6.
#
# usage:
#
#  startLog "~/logfiles/mylog"
#
function startLog
{
  local LOG="$1"
  local DIR=$(dirname "${LOG}")
  local TLOG=/tmp/startLog-$RANDOM

  if [ ! -t 1 ]
  then
    echo "startLog(): logging appears to be enabled already"
    return 1
  else
    if [ ! -d "${DIR}" ]
    then
      mkdir -p "${DIR}" 2>&1 || 
        abort "startLog(): couldn't create ${DIR}"
    fi

    touch "${LOG}" || abort "startLog(): can't access ${LOG}"

    mkfifo ${TLOG}
    trap "rm -f ${TLOG}" EXIT

    tee <${TLOG} "${LOG}" &

    exec 6>&1  # save the existing stdout
    exec 1>&-
    exec 1>>${TLOG}
    echo "startLog(): $(date)"
  fi
}



#####################################################################
# stopLog "<log file name>"
#
# Stop logging stdout to both a log file and the terminal.
# Restores FD 1 from FD 6 saved by startLog()
#
# usage:
#
#  stopLog
#
function stopLog
{
  if [ -t 1 ]
  then
    echo "stopLog(): appears to be no log to stop"
    return
  else
    echo "stopLog(): $(date)"
    exec 1>&6 6>&-
  fi
}
