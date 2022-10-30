#!/bin/bash
#
# Restore last modified timestamps for all artifacts to commit date
#

# Setup OS compatiblity
OSname=$(uname -s)
if [ "${OSname}" == "Darwin" ] ; then
  :
elif [ "$(expr substr ${OSname} 1 5)" == "Linux" ]; then
  OSname=Linux
else
  echo "This script is not implemented for OS ${OSname}"
  exit 1
fi


# We need some exceptions because of faults in the repository,
# where using the last commit date is not reflecting the date
# that the artifacts were added.
# The function returns a time string suitable to 'touch' if
# an exception exists for the filename passed in.
# exception_for <filename> <resultVariable>
function exception_for()
{
  local file=$1
  local resVar=$2

  printf -v "$resVar" ''
  if [[ "$file" == com/google/inject/extensions/guice-servlet/4.0-gb2/guice-servlet-4.0-gb2.pom* ]] ; then
    printf -v "$resVar" '201509181957.00'
  fi
}


# Convert from Epoch to format accepted by 'touch'
# convert_ts <timestamp>
function convert_ts()
{
  if [[ ${OSname} == 'Darwin' ]] ; then
    date -j -f %s ${mtime} +%Y%m%d%H%M.%S
  elif [[ ${OSname} == 'Linux' ]]; then
    date --date="@${mtime}" +%Y%m%d%H%M.%S
  fi
}


# Set the modification file of a file
# set_mtime <epoch timestamp> <filename>
function set_mtime()
{
  local mtime=$1
  local file=$2
  local timeString

  exception_for "${file}" timeString
  if [ -z "${timeString}" ] ; then
    timeString=$(convert_ts ${mtime})
  fi
  touch -m -t ${timeString} ${file}
}


git log --pretty=%at --name-status --reverse | while read a b c
do
  [ -z "${a}" ] && continue

  if [ -z "${b}" ] ; then
    mtime=${a}
    continue
  fi

  if [[ ${a} == A || ${a} == M ]] ; then
    if [[ -f ${b} ]] ; then
      set_mtime ${mtime} ${b}
    fi
  elif [[ ${a} == R* ]] ; then
    if [[ -n "${c}" && -f ${c} ]] ; then
      set_mtime ${mtime} ${c}
    fi
  fi
done
