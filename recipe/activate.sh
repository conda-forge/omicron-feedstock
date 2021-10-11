#!/usr/bin/env bash
#
# Configure a conda environment for Omicron
#

# preserve the user's existing setting
if [ ! -z "${OMICRON_HTML+x}" ]; then
	export CONDA_BACKUP_OMICRON_HTML="${OMICRON_HTML}"
fi

# set the variable
export OMICRON_HTML="${CONDA_PREFIX}/share/omicron/html"
