#!/usr/bin/env bash

# -*- mode: jinja-shell -*-

source .scripts/logging_utils.sh

set -xe

MINIFORGE_HOME=${MINIFORGE_HOME:-${HOME}/miniforge3}

( startgroup "Installing a fresh version of Miniforge" ) 2> /dev/null

MINIFORGE_URL="https://github.com/conda-forge/miniforge/releases/latest/download"
MINIFORGE_FILE="Mambaforge-Linux-$(uname -m).sh"
curl -L -O "${MINIFORGE_URL}/${MINIFORGE_FILE}"
rm -rf ${MINIFORGE_HOME}
bash $MINIFORGE_FILE -b -p ${MINIFORGE_HOME}

( endgroup "Installing a fresh version of Miniforge" ) 2> /dev/null

( startgroup "Configuring conda" ) 2> /dev/null

source ${MINIFORGE_HOME}/etc/profile.d/conda.sh
conda activate base

mamba install --update-specs --yes --channel conda-forge --strict-channel-priority \
    pip mamba conda-build boa conda-forge-ci-setup=3
mamba update --update-specs --yes --channel conda-forge --strict-channel-priority \
    pip mamba conda-build boa conda-forge-ci-setup=3

set -x

#echo -e "\n\nSetting up the condarc and mangling the compiler."
echo -e "\n\nSetting up the condarc."
setup_conda_rc ./ ./recipe ./.ci_support/${CONFIG}.yaml

#if [[ "${CI:-}" != "" ]]; then
#  mangle_compiler ./ ./recipe .ci_support/${CONFIG}.yaml
#fi

echo -e "\n\nRunning the build setup script."

# source run_conda_forge_build_setup

# equivalent of run_conda_forge_build_setup
set -x
export PYTHONUNBUFFERED=1

echo -e "\n\nAbout to set conda config"

conda config --env --set show_channel_urls true
conda config --env --set auto_update_conda false
conda config --env --set add_pip_as_python_dependency false
# Otherwise packages that don't explicitly pin openssl in their requirements
# are forced to the newest OpenSSL version, even if their dependencies don't
# support it.
conda config --env --append aggressive_update_packages ca-certificates # add something to make sure the key exists
conda config --env --remove-key aggressive_update_packages
conda config --env --append aggressive_update_packages ca-certificates
conda config --env --append aggressive_update_packages certifi

echo -e "\n\nDone setting conda config"

export "CONDA_BLD_PATH=${PWD}/build_artifacts"
echo "$PWD"
echo "${CONDA_PREFIX} | ${CONDA_BLD_PATH}"
ls -l "${CONDA_PREFIX}" || echo "Failed to list conda prefix"
ls -l "${CONDA_BLD_PATH}" || echo "Failed to list conda build path"

# 2 cores available on TravisCI workers: https://docs.travis-ci.com/user/reference/overview/
# CPU_COUNT is passed through conda build: https://github.com/conda/conda-build/pull/1149
export CPU_COUNT="${CPU_COUNT:-2}"

echo -e "\n\nCreating activate.d dir and script"

mkdir -p "${CONDA_PREFIX}/etc/conda/activate.d"
echo "export CONDA_BLD_PATH='${CONDA_BLD_PATH}'"         > "${CONDA_PREFIX}/etc/conda/activate.d/conda-forge-ci-setup-activate.sh"
if [ -n "${CPU_COUNT-}" ]; then
    echo "export CPU_COUNT='${CPU_COUNT}'"                  >> "${CONDA_PREFIX}/etc/conda/activate.d/conda-forge-ci-setup-activate.sh"
fi
echo "export PYTHONUNBUFFERED='${PYTHONUNBUFFERED}'"    >> "${CONDA_PREFIX}/etc/conda/activate.d/conda-forge-ci-setup-activate.sh"

echo -e "\n\nDone with activate script"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

echo -e "\n\nSourcing cross compile support | SCRIPT_DIR: ${SCRIPT_DIR}"

source ${SCRIPT_DIR}/cross_compile_support.sh

echo -e "\n\nAfter cross compile support source"

conda info
conda config --env --show-sources
conda list --show-channel-urls


### END OF run_conda_forge_build_setup ####


( endgroup "Configuring conda" ) 2> /dev/null

echo -e "\n\nMaking the build clobber file"
make_build_number ./ ./recipe ./.ci_support/${CONFIG}.yaml

if [[ -f LICENSE.txt ]]; then
  cp LICENSE.txt "recipe/recipe-scripts-license.txt"
fi

if [[ "${BUILD_WITH_CONDA_DEBUG:-0}" == 1 ]]; then
    if [[ "x${BUILD_OUTPUT_ID:-}" != "x" ]]; then
        EXTRA_CB_OPTIONS="${EXTRA_CB_OPTIONS:-} --output-id ${BUILD_OUTPUT_ID}"
    fi
    conda debug ./recipe -m ./.ci_support/${CONFIG}.yaml \
        ${EXTRA_CB_OPTIONS:-} \
        --clobber-file ./.ci_support/clobber_${CONFIG}.yaml

    # Drop into an interactive shell
    /bin/bash
else

    if [[ "${HOST_PLATFORM}" != "${BUILD_PLATFORM}" ]]; then
        EXTRA_CB_OPTIONS="${EXTRA_CB_OPTIONS:-} --no-test"
    fi

    conda mambabuild ./recipe -m ./.ci_support/${CONFIG}.yaml \
        --suppress-variables ${EXTRA_CB_OPTIONS:-} \
        --clobber-file ./.ci_support/clobber_${CONFIG}.yaml
    ( startgroup "Validating outputs" ) 2> /dev/null

    validate_recipe_outputs "${FEEDSTOCK_NAME}"

    ( endgroup "Validating outputs" ) 2> /dev/null

    ( startgroup "Uploading packages" ) 2> /dev/null

    if [[ "${UPLOAD_PACKAGES}" != "False" ]] && [[ "${IS_PR_BUILD}" == "False" ]]; then
      upload_package --validate --feedstock-name="${FEEDSTOCK_NAME}" ./ ./recipe ./.ci_support/${CONFIG}.yaml
    fi

    ( endgroup "Uploading packages" ) 2> /dev/null
fi
