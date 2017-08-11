#!/bin/bash


retval=

function usage() {
  [ "$1" != "" ] && echo -e "$1"
  echo "usage: `basename $0` <config_file>"
  echo " Prepares the REPO_DOC_ROOT folder. ($REPO_DOC_ROOT)."
  echo " REPO_DOC_ROOT is set in config_file. "
  echo " REPO_DOC_ROOT is the directory where repo files will be located."
  echo "Options:"
  echo "  config_file   -  see install.conf for an example"
  exit 254
}

function error() {
  echo -e "ERROR: $1"
  exit 254
}

#### SETUP ####

config_file=$1
[ $# -ne 1 ] && usage "Missing required config file." 
[ ! -f $1 ] && usage "Config file does not exist: $config_file"

# Set values from the config file
source $config_file


RPMS_DIR=$INSTDIR/repo_files/rpms/centos7
FILES_DIR=$INSTDIR/repo_files/files
HDP_DIR=$INSTDIR/repo_files/HDP
AMBARI_DIR=$INSTDIR/repo_files/AMBARI
HDP_UTILS_DIR=$INSTDIR/repo_files/HDP-UTILS


[ "$REPO_DOC_ROOT" = "" ] && usage "REPO_DOC_ROOT is not set in the install.conf file"
[ "$INSTDIR" = "" ] && error "INSTDIR is not set in the install.conf file"
[ ! -d $REPO_DOC_ROOT ] && error "The repo doc root does not exist: $REPO_DOC_ROOT.\Please ensure that the repo server is configured."



######## FUNCTIONS ##########

function get_base_pkg_name() {
  base=`basename $1`
  retval=`echo "$base"  |sed -e 's/\(.*\)-centos7.*/\1/g'`
}


function prepare_repos() {
  local l_src_path=$1    #List of paths/files space delimited (e.g. globbed)
  local l_url_suffix=$2  #This is going to come from the structure of the tar dirs

  echo "Untarring repo files (this may take a minute)...."
  for i in $l_src_path ;do
    get_base_pkg_name $i
    base=$retval
    mkdir -p $REPO_DOC_ROOT/$base

    echo " -- UNTARRING $i "
    tar xzf $i -C $REPO_DOC_ROOT/$base

    urls_out+="\n$base  http://${HOSTNAME}/$base/$l_url_suffix"
  done
}

######## MAIN ##########

# RPMS
echo " -- creating yum repo"
echo "Copying repo files (this may take a minute)...."
cp -pr $RPMS_DIR $REPO_DOC_ROOT

createrepo $REPO_DOC_ROOT/rpms/centos7
urls_out+="\nRPMs  http://${HOSTNAME}/rpms/centos7"


# FILES
echo " -- creating files repo"
echo "Copying repo files (this may take a minute)...."
cp -pr $FILES_DIR/files $REPO_DOC_ROOT
urls_out+="\nFiles http://${HOSTNAME}/files"


# HORTONWORKS REPOS
prepare_repos "$HDP_DIR/*"  "HDP/centos7"
prepare_repos "$AMBARI_DIR/*"  "ambari/centos7"
prepare_repos "$HDP_UTILS_DIR/*"  ""


echo " -------------------------"
echo " ------ REPO URLS --------"
echo -e "$urls_out"



