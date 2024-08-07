#!/bin/bash
###########################################################################

###########################################################################
###  YOU CAN MODIFY THE FOLLOWING VARIABLES
###########################################################################

###########################################################################
###  DO NOT MODIFY THE REST OF THE SCRIPT
###########################################################################

SCRIPT=`basename "$0"`
DIRSCRIPT=`dirname "$0"`
DIRSCRIPT=`(cd "${DIRSCRIPT}" ; echo ${PWD})`

ANT_HOME=${DIRSCRIPT}/../tpcl/apache-ant-1.10.9

###########################################################################
###  Usage

Usage() {
	echo ""
	echo Usage: "${SCRIPT} [options] input template|existing.ods output.ods"
	echo ""
	echo Options:
	#echo "  -env <environment> The name of the environment to use when exporting one profile file."
	#echo "                     Ignored when exporting an application, EAR or folder."
	echo ""
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

PrepareVariables() {
	case "${TEMPLATE}" in
	none)
		TEMPLATE=${DIRSCRIPT}/../templates/ods.ods
		;;
	esac
	
	[ "${ENV}" = "" ] && ENV=`basename "${INPUT}" .substvar`
}

###########################################################################
###  Export configuration from one profile file

ExportFromProfile() {

	PrepareVariables
	
	CheckFile "${INPUT}"
	CheckFile "${TEMPLATE}"
	
	typeset MODULE_PROPS=${DIRSCRIPT}/../templates/module.bwm
	CheckFile "${MODULE_PROPS}"
	
	"${ANT_HOME}/bin/ant" -f "${DIRSCRIPT}/../lib/export-ant.xml" "-DAPPCONFIG=${INPUT}" "-DMODULE_CONFIG=${MODULE_PROPS}" "-DTEMPLATE=${TEMPLATE}" "-DODS=${OUTPUT}" -DDATE=20210213 "-DENV=${ENV}" "-DSHEET_NAME=${SHEET_NAME}"
}

###########################################################################
###  Export configuration from one application folder

ExportFromApplication() {
	
	PrepareVariables
	
	CheckFolder "${INPUT}"
	CheckFolder "${INPUT}/META-INF"
	CheckFile "${TEMPLATE}"
	
	typeset TMPL=/tmp/$$.ods
	cp "${TEMPLATE}" "${TMPL}"

	typeset MODULE_PROPS=${INPUT}/../`basename "${INPUT}" .application`/META-INF/module.bwm
	CheckFile "${MODULE_PROPS}"

	for F in "${INPUT}"/META-INF/*.substvar ; do
		CheckFile "${F}"
		
		"${ANT_HOME}/bin/ant" -f "${DIRSCRIPT}/../lib/export-ant.xml" "-DAPPCONFIG=${F}" "-DMODULE_CONFIG=${MODULE_PROPS}" "-DTEMPLATE=${TMPL}" "-DODS=${OUTPUT}" -DDATE=2021 -DENV=`basename "${F}" .substvar`  "-DSHEET_NAME=${SHEET_NAME}"
		mv "${OUTPUT}" "${TMPL}"
	done
	cp "${TMPL}" "${OUTPUT}"
}

###########################################################################
###  Export configuration from ALL profile files inside one EAR 

ExportFromEAR() {

	CheckFile "${INPUT}"

	typeset FOLDER=/tmp/$$
	unzip "${INPUT}" -d "${FOLDER}"

	PrepareVariables
	
	CheckFolder "${FOLDER}"
	CheckFolder "${FOLDER}/META-INF"
	CheckFile "${TEMPLATE}"

	typeset TMPL=/tmp/$$.ods
	cp "${TEMPLATE}" "${TMPL}"

	for F in "${FOLDER}"/META-INF/*.substvar ; do 
		CheckFile "${F}"
		
		"${ANT_HOME}/bin/ant" -f "${DIRSCRIPT}/../lib/export-ant.xml" "-DAPPCONFIG=${F}" "-DMODULE_CONFIG=${DIRSCRIPT}/../templates/module.bwm" "-DTEMPLATE=${TMPL}" "-DODS=${OUTPUT}" -DDATE=20221 -DENV=`basename "${F}" .substvar` "-DSHEET_NAME=${SHEET_NAME}"
		mv "${OUTPUT}" "${TMPL}"
	done
	cp "${TMPL}" "${OUTPUT}"

	rm -rf "${FOLDER}"
}

###########################################################################
###  Export configuration from ALL application folders

ExportFromFolder() {

	CheckFolder "${INPUT}"

	PrepareVariables
	
	CheckFile "${TEMPLATE}"

	typeset TMPL=/tmp/$$.ods
	cp "${TEMPLATE}" "${TMPL}"

	for F in "${INPUT}"/* ; do
		if [ -d "${F}" ] ; then
			"${DIRSCRIPT}/${SCRIPT}" "${F}" "${TMPL}" "${TMPL}" #--sheet "${SHEET_NAME}"
		fi
	done
	for F in "${INPUT}"/* ; do
		CheckFile "${F}"
		
		if [ -f "${F}/META-INF/TIBCO.xml" ] ; then
			"${DIRSCRIPT}/${SCRIPT}" "${F}" "${TMPL}" "${TMPL}" #--sheet "${SHEET_NAME}"
		fi
	done
	cp "${TMPL}" "${OUTPUT}"
}

###########################################################################
# Parse command line

typeset INPUT=""
typeset TEMPLATE=""
typeset OUTPUT=""

typeset ENV=""
typeset SHEET_NAME=Configuration
typeset VALUE_ID=ID
typeset VALUE_ENVIRONMENT=Environment
typeset VALUE_DESCRIPTION=Description

while [ ! "$#" = "0" ] ; do
	case "$1" in
	#--env)
	#	shift ; ENV=$1 ; [ "${ENV}" = "" ] && Usage ;;
	#--sheet)
	#	shift ; SHEET_NAME=$1 ; [ "${SHEET_NAME}" = "" ] && Usage ;;
	--*)	;;
	*)
		if [ "${INPUT}" = "" ] ; then
			INPUT=$1
		elif [ "${TEMPLATE}" = "" ] ; then
			TEMPLATE=$1
		elif [ "${OUTPUT}" = "" ] ; then
			OUTPUT=$1
		fi
		;;
	esac
	shift
done
[ "${INPUT}" = "" -o "${TEMPLATE}" = "" -o "${OUTPUT}" = "" ] && Usage

case "${INPUT}" in
*.profile)
	ExportFromProfile
	;;
*.substvar)
	ExportFromProfile
	;;
*.ear)
	ExportFromEAR
	;;
*)
    if [ -f "${INPUT}/META-INF/TIBCO.xml" ] ; then
		ExportFromApplication
	else
		ExportFromFolder
	fi
	;;
esac
exit $?

###########################################################################
###  END OF FILE  #########################################################
###########################################################################
