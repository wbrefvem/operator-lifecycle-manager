#!/usr/bin/env bash

# requires helm v3 to be installed
# the output of "helm template" is not stable between versions 2 and 3
if helm version 2>/dev/null | grep -v -q -E 'Version:"v3\.'; then
    echo "error: helm version 3 is required"
    exit 1
fi

if [[ ${#@} -lt 3 ]]; then
    echo "Usage: $0 semver chart values"
    echo "* semver: semver-formatted version for this package"
    echo "* chart: the directory to output the chart"
    echo "* values: the values file"
    exit 1
fi

version=$1
chartdir=$2
values=$3

charttmpdir=`mktemp -d 2>/dev/null || mktemp -d -t 'charttmpdir'`

charttmpdir=${charttmpdir}/chart

cp -R deploy/chart/ ${charttmpdir}
echo "Version: $1" >> ${charttmpdir}/Chart.yaml

mkdir -p ${chartdir}

helm template -n olm -f ${values} ${charttmpdir} --output-dir ${charttmpdir}

cp -R ${charttmpdir}/olm/templates/. ${chartdir}
