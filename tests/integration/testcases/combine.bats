bats_load_library 'bats/bats-support/load.bash'
bats_load_library 'bats/bats-assert/load.bash'
bats_load_library 'bats/bats-file/load.bash'
load 'lib/common.bash'


@test "combine: check if image directory has a valid tezi image" {
    local ci_dockerhub_login=""

    if [ "${TCB_UNDER_CI}" = "1" ] && \
       [ -n "${CI_DOCKER_HUB_PULL_USER}" ] && \
       [ -n "${CI_DOCKER_HUB_PULL_PASSWORD}" ]; then
        ci_dockerhub_login="1"
    fi

    local COMPOSE='docker-compose.yml'
    cp "$SAMPLES_DIR/compose/hello/docker-compose.yml" "$COMPOSE"

    rm -rf bundle
    run torizoncore-builder bundle "$COMPOSE" \
        ${ci_dockerhub_login:+"--login" "${CI_DOCKER_HUB_PULL_USER}" "${CI_DOCKER_HUB_PULL_PASSWORD}"}
    assert_success

    if [ "${ci_dockerhub_login}" = "1" ]; then
        assert_output --partial "Attempting to log in to"
    fi

    local FILES="image.json *.zst"
    for FILE in $FILES
    do
        unpack-image $DEFAULT_TEZI_IMAGE
        local IMAGE_DIR=$(echo $DEFAULT_TEZI_IMAGE | sed 's/\.tar$//g')
        local OUTPUT_DIR=$(mktemp -d tmpdir.XXXXXXXXXXXXXXXXXXXXXXXXX)
        rm $IMAGE_DIR/$FILE

        run torizoncore-builder combine $IMAGE_DIR $OUTPUT_DIR
        assert_failure
        assert_output --partial "Error: directory $IMAGE_DIR does not contain a valid TEZI image"

        rm -rf "$IMAGE_DIR" "$OUTPUT_DIR"
    done

    rm -rf "$COMPOSE" bundle
}

@test "combine: run with the deprecated --image-directory switch" {
    local ci_dockerhub_login=""

    if [ "${TCB_UNDER_CI}" = "1" ] && \
       [ -n "${CI_DOCKER_HUB_PULL_USER}" ] && \
       [ -n "${CI_DOCKER_HUB_PULL_PASSWORD}" ]; then
        ci_dockerhub_login="1"
    fi

    local COMPOSE='docker-compose.yml'
    cp "$SAMPLES_DIR/compose/hello/docker-compose.yml" "$COMPOSE"

    rm -rf bundle
    run torizoncore-builder bundle "$COMPOSE" \
        ${ci_dockerhub_login:+"--login" "${CI_DOCKER_HUB_PULL_USER}" "${CI_DOCKER_HUB_PULL_PASSWORD}"}
    assert_success

    if [ "${ci_dockerhub_login}" = "1" ]; then
        assert_output --partial "Attempting to log in to"
    fi

    unpack-image $DEFAULT_TEZI_IMAGE
    local IMAGE_DIR=$(echo $DEFAULT_TEZI_IMAGE | sed 's/\.tar$//g')
    local OUTPUT_DIR=$(mktemp -d tmpdir.XXXXXXXXXXXXXXXXXXXXXXXXX)

    run torizoncore-builder combine --image-directory $IMAGE_DIR \
                                    $OUTPUT_DIR
    assert_failure
    assert_output --partial "Error: the switch --image-directory has been removed"
    assert_output --partial "please provide the image directory without passing the switch."

    rm -rf "$COMPOSE" bundle "$OUTPUT_DIR" "$IMAGE_DIR"
}

@test "combine: run with the deprecated --output-directory switch" {
    local ci_dockerhub_login=""

    if [ "${TCB_UNDER_CI}" = "1" ] && \
       [ -n "${CI_DOCKER_HUB_PULL_USER}" ] && \
       [ -n "${CI_DOCKER_HUB_PULL_PASSWORD}" ]; then
        ci_dockerhub_login="1"
    fi

    local COMPOSE='docker-compose.yml'
    cp "$SAMPLES_DIR/compose/hello/docker-compose.yml" "$COMPOSE"

    rm -rf bundle
    run torizoncore-builder bundle "$COMPOSE" \
        ${ci_dockerhub_login:+"--login" "${CI_DOCKER_HUB_PULL_USER}" "${CI_DOCKER_HUB_PULL_PASSWORD}"}
    assert_success

    if [ "${ci_dockerhub_login}" = "1" ]; then
        assert_output --partial "Attempting to log in to"
    fi

    unpack-image $DEFAULT_TEZI_IMAGE
    local IMAGE_DIR=$(echo $DEFAULT_TEZI_IMAGE | sed 's/\.tar$//g')
    local OUTPUT_DIR=$(mktemp -d tmpdir.XXXXXXXXXXXXXXXXXXXXXXXXX)

    run torizoncore-builder combine $IMAGE_DIR \
                                    --output-directory $OUTPUT_DIR
    assert_failure
    assert_output --partial "Error: the switch --output-directory has been removed"
    assert_output --partial "please provide the output directory without passing the switch."

    rm -rf "$COMPOSE" bundle "$OUTPUT_DIR" "$IMAGE_DIR"
}

@test "combine: check without --bundle-directory parameter" {
    local ci_dockerhub_login=""

    if [ "${TCB_UNDER_CI}" = "1" ] && \
       [ -n "${CI_DOCKER_HUB_PULL_USER}" ] && \
       [ -n "${CI_DOCKER_HUB_PULL_PASSWORD}" ]; then
        ci_dockerhub_login="1"
    fi

    local COMPOSE='docker-compose.yml'
    cp "$SAMPLES_DIR/compose/hello/docker-compose.yml" "$COMPOSE"

    rm -rf bundle
    run torizoncore-builder bundle "$COMPOSE" \
        ${ci_dockerhub_login:+"--login" "${CI_DOCKER_HUB_PULL_USER}" "${CI_DOCKER_HUB_PULL_PASSWORD}"}
    assert_success

    if [ "${ci_dockerhub_login}" = "1" ]; then
        assert_output --partial "Attempting to log in to"
    fi

    unpack-image $DEFAULT_TEZI_IMAGE
    local IMAGE_DIR=$(echo $DEFAULT_TEZI_IMAGE | sed 's/\.tar$//g')
    local OUTPUT_DIR=$(mktemp -d -u tmpdir.XXXXXXXXXXXXXXXXXXXXXXXXX)

    run torizoncore-builder combine $IMAGE_DIR $OUTPUT_DIR
    assert_success
    run ls -l $OUTPUT_DIR/$COMPOSE
    assert_success

    check-file-ownership-as-workdir "$OUTPUT_DIR"

    rm -rf "$COMPOSE" bundle "$OUTPUT_DIR" "$IMAGE_DIR"
}

@test "combine: check with --bundle-directory parameters" {
    local ci_dockerhub_login=""

    if [ "${TCB_UNDER_CI}" = "1" ] && \
       [ -n "${CI_DOCKER_HUB_PULL_USER}" ] && \
       [ -n "${CI_DOCKER_HUB_PULL_PASSWORD}" ]; then
        ci_dockerhub_login="1"
    fi

    local COMPOSE='docker-compose.yml'
    cp "$SAMPLES_DIR/compose/hello/docker-compose.yml" "$COMPOSE"

    local BUNDLE_DIR=$(mktemp -d -u tmpdir.XXXXXXXXXXXXXXXXXXXXXXXXX)

    run torizoncore-builder bundle --bundle-directory "$BUNDLE_DIR" "$COMPOSE" \
        ${ci_dockerhub_login:+"--login" "${CI_DOCKER_HUB_PULL_USER}" "${CI_DOCKER_HUB_PULL_PASSWORD}"}
    assert_success

    if [ "${ci_dockerhub_login}" = "1" ]; then
        assert_output --partial "Attempting to log in to"
    fi

    unpack-image $DEFAULT_TEZI_IMAGE
    local IMAGE_DIR=$(echo $DEFAULT_TEZI_IMAGE | sed 's/\.tar$//g')
    local OUTPUT_DIR=$(mktemp -d -u tmpdir.XXXXXXXXXXXXXXXXXXXXXXXXX)

    run torizoncore-builder combine --bundle-directory $BUNDLE_DIR \
                                    $IMAGE_DIR $OUTPUT_DIR
    assert_success
    run ls -l $OUTPUT_DIR/$COMPOSE
    assert_success

    check-file-ownership-as-workdir "$OUTPUT_DIR"

    rm -rf "$COMPOSE" "$BUNDLE_DIR" "$OUTPUT_DIR" "$IMAGE_DIR"
}

@test "combine: check with --image-autoinstall" {
    local ci_dockerhub_login=""

    if [ "${TCB_UNDER_CI}" = "1" ] && \
       [ -n "${CI_DOCKER_HUB_PULL_USER}" ] && \
       [ -n "${CI_DOCKER_HUB_PULL_PASSWORD}" ]; then
        ci_dockerhub_login="1"
    fi

    local LICENSE_FILE="license-fc.html"
    local LICENSE_DIR="$SAMPLES_DIR/installer/$LICENSE_FILE"
    local COMPOSE='docker-compose.yml'
    cp "$SAMPLES_DIR/compose/hello/docker-compose.yml" "$COMPOSE"

    rm -rf bundle
    run torizoncore-builder bundle "$COMPOSE" \
        ${ci_dockerhub_login:+"--login" "${CI_DOCKER_HUB_PULL_USER}" "${CI_DOCKER_HUB_PULL_PASSWORD}"}
    assert_success

    if [ "${ci_dockerhub_login}" = "1" ]; then
        assert_output --partial "Attempting to log in to"
    fi

    unpack-image $DEFAULT_TEZI_IMAGE
    local IMAGE_DIR=$(echo $DEFAULT_TEZI_IMAGE | sed 's/\.tar$//g')
    local OUTPUT_DIR=$(mktemp -d -u tmpdir.XXXXXXXXXXXXXXXXXXXXXXXXX)

    # Test if output licence filename will override current licence filename
    # when passing --image-licence argument
    run torizoncore-builder combine $IMAGE_DIR $OUTPUT_DIR \
                                    --image-autoinstall \
                                    --image-licence $LICENSE_DIR
    assert_failure
    assert_output --partial \
        "Error: To enable the auto-installation feature you must accept the licence \"$LICENSE_FILE\""

    run torizoncore-builder combine $IMAGE_DIR $OUTPUT_DIR
    assert_success
    run grep autoinstall $OUTPUT_DIR/image.json
    assert_output --partial "false"

    rm -rf "$OUTPUT_DIR"

    run torizoncore-builder combine $IMAGE_DIR $OUTPUT_DIR --image-autoinstall \
                                                           --image-accept-licence
    assert_success
    run grep autoinstall $OUTPUT_DIR/image.json
    assert_output --partial "true"

    rm -rf "$OUTPUT_DIR"

    run torizoncore-builder combine $IMAGE_DIR $OUTPUT_DIR --no-image-autoinstall
    assert_success
    run grep autoinstall $OUTPUT_DIR/image.json
    assert_output --partial "false"

    rm -rf "$COMPOSE" "$OUTPUT_DIR" "$IMAGE_DIR"
}

@test "combine: check with --image-autoreboot" {
    local ci_dockerhub_login=""

    if [ "${TCB_UNDER_CI}" = "1" ] && \
       [ -n "${CI_DOCKER_HUB_PULL_USER}" ] && \
       [ -n "${CI_DOCKER_HUB_PULL_PASSWORD}" ]; then
        ci_dockerhub_login="1"
    fi

    local COMPOSE='docker-compose.yml'
    local REG_EX_GENERATED='^\s*reboot\s+-f\s*#\s*torizoncore-builder\s+generated'
    cp "$SAMPLES_DIR/compose/hello/docker-compose.yml" "$COMPOSE"

    rm -rf bundle
    run torizoncore-builder bundle "$COMPOSE" \
        ${ci_dockerhub_login:+"--login" "${CI_DOCKER_HUB_PULL_USER}" "${CI_DOCKER_HUB_PULL_PASSWORD}"}
    assert_success

    if [ "${ci_dockerhub_login}" = "1" ]; then
        assert_output --partial "Attempting to log in to"
    fi

    unpack-image $DEFAULT_TEZI_IMAGE
    local IMAGE_DIR=$(echo $DEFAULT_TEZI_IMAGE | sed 's/\.tar$//g')
    local OUTPUT_DIR=$(mktemp -d -u tmpdir.XXXXXXXXXXXXXXXXXXXXXXXXX)

    run torizoncore-builder combine $IMAGE_DIR $OUTPUT_DIR
    assert_success
    run grep -E $REG_EX_GENERATED $OUTPUT_DIR/wrapup.sh
    refute_output

    rm -rf "$OUTPUT_DIR"

    run torizoncore-builder combine $IMAGE_DIR $OUTPUT_DIR --image-autoreboot
    assert_success
    run grep -E $REG_EX_GENERATED $OUTPUT_DIR/wrapup.sh
    assert_success

    rm -rf "$OUTPUT_DIR"

    run torizoncore-builder combine $IMAGE_DIR $OUTPUT_DIR --no-image-autoreboot
    assert_success
    run grep -E $REG_EX_GENERATED $OUTPUT_DIR/wrapup.sh
    refute_output

    rm -rf "$COMPOSE" "$OUTPUT_DIR" "$IMAGE_DIR"
}
