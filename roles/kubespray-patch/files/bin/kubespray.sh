#!/usr/bin/env bash
set -eux
# always call this symlinked
# kubespray-<name>-<stage>-<variant>.sh
# This always assumes that the script will run in base dir of kubespray
# the name,stage and variant will be mapped to the variables

function pick
{
    for PATHNAME in "$@"; do
        if [ -e "$PATHNAME" ]; then
            echo $PATHNAME
            return
        fi
    done
}

BASENAME=$(basename -s .sh "$0")
DIRNAME=$(dirname "$0")

# Split basename into array
ARRAY=(${BASENAME//-/ })

CONFIG_NAME=${ARRAY[1]}
CONFIG_STAGE=${ARRAY[2]}
CONFIG_VARIANT=${ARRAY[3]}

ALL_FILE=$(pick\
 "inventory/clusters/$CONFIG_NAME/$CONFIG_STAGE/all.yaml"\
 "inventory/clusters/$CONFIG_NAME/all.yaml")

[ -n "${ALL_FILE}" ] && OPTION_ALL_FILE="-i $ALL_FILE"

INVENTORY_FILE=$(pick "inventory/clusters/${CONFIG_NAME}/${CONFIG_STAGE}/inventory.yaml")
 INVENTORY_DIR=$(pick "inventory/${CONFIG_VARIANT}")

[ -z "${INVENTORY_DIR}" ] && echo "inventory dir does not exist: inventory/${CONFIG_NAME}/${CONFIG_STAGE}" && exit 1

ansible-playbook\
    $OPTION_ALL_FILE\
    -i "$INVENTORY_FILE"\
    -i "$INVENTORY_DIR"\
    cluster.yml\
        --flush-cache\
        -b \
        "$@"

