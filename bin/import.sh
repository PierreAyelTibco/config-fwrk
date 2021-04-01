#!/bin/bash
###########################################################################

###########################################################################
###  YOU CAN MODIFY THE FOLLOWING VARIABLES
###########################################################################

###########################################################################
###  DO NOT MODIFY THE REST OF THE SCRIPT
###########################################################################

Usage() {
	echo ""
	echo ${SCRIPT}
	exit -1
}

###########################################################################

CheckFile() {
	typeset FILE=$1
	if [ ! -f "${FILE}" ] ; then
		echo Error: file ${FILE} does not exist or cannot be found...
		exit -2
	fi
}

###########################################################################

CheckFolder() {
	typeset FILE=$1
	if [ ! -d "${FILE}" ] ; then
		echo Error: folder ${FILE} does not exist or cannot be found...
		exit -2
	fi
}

###########################################################################

SCRIPT=`basename "$0"`
DIRSCRIPT=`dirname "$0"`
DIRSCRIPT=`(cd "${DIRSCRIPT}" ; echo ${PWD})`

ANT_HOME=${DIRSCRIPT}/../tpcl/apache-ant-1.10.9

###########################################################################
### Update one profile file

ImportIntoProfile() {
	
	[ $# -lt 4 ] && Usage
	
	typeset OUTPUT=$4
	typeset APP=/tmp/$$.xml
	typeset GLOBAL=/tmp/$$.xml
	
	CheckFile "${INPUT}"
	CheckFile "${APP_CONFIG}"
	CheckFile "${GLOBAL_CONFIG}"
	
	"${ANT_HOME}/bin/ant" -f "${DIRSCRIPT}/../lib/create-AppConfig-from-ODS-ant.xml" "-DODS=${APP_CONFIG}" "-DOUTPUT=${APP}"
	"${ANT_HOME}/bin/ant" -f "${DIRSCRIPT}/../lib/create-AppConfig-from-ODS-ant.xml" "-DODS=${GLOBAL_CONFIG}" "-DOUTPUT=${GLOBAL}"
	"${ANT_HOME}/bin/ant" -f "${DIRSCRIPT}/../lib/import-ant.xml" "-DPROFILE_IN=${INPUT}" "-DPROFILE_OUT=${OUTPUT}" "-DAPP_APPCONFIG=${APP}" "-DGLOBAL_APPCONFIG=${GLOBAL}" -DENV=`basename "${INPUT}" .substvar`

	rm -f "${APP}"
	rm -f "${GLOBAL}"
}

###########################################################################
### Update all profile files within an application

ImportIntoApplication() {

	typeset APP=/tmp/$$.xml
	typeset GLOBAL=/tmp/$$.xml

	CheckFolder "${INPUT}"
	CheckFolder "${INPUT}/META-INF"
	CheckFile "${APP_CONFIG}"
	CheckFile "${GLOBAL_CONFIG}"

	"${ANT_HOME}/bin/ant" -f "${DIRSCRIPT}/../lib/create-AppConfig-from-ODS-ant.xml" "-DODS=${APP_CONFIG}" "-DOUTPUT=${APP}"
	"${ANT_HOME}/bin/ant" -f "${DIRSCRIPT}/../lib/create-AppConfig-from-ODS-ant.xml" "-DODS=${GLOBAL_CONFIG}" "-DOUTPUT=${GLOBAL}"
	for F in "${INPUT}"/META-INF/*.substvar ; do
		CheckFile "${F}"
		
		"${ANT_HOME}/bin/ant" -f "${DIRSCRIPT}/../lib/import-ant.xml" "-DPROFILE_IN=${F}" "-DPROFILE_OUT=${F}" "-DAPP_APPCONFIG=${APP}" "-DGLOBAL_APPCONFIG=${GLOBAL}" -DENV=`basename "${F}" .substvar`
	done

	rm -f "${APP}"
	rm -f "${GLOBAL}"
}

###########################################################################
# Parse command line

[ $# -lt 3 ] && Usage

INPUT=$1
APP_CONFIG=$2
GLOBAL_CONFIG=$3

case "${INPUT}" in
*.profile)	
	ImportIntoProfile $*
	;;
*.substvar)
	ImportIntoProfile $*
	;;
*.application)
	ImportIntoApplication
	;;
esac
exit $?

###########################################################################
###  END OF FILE  #########################################################
###########################################################################