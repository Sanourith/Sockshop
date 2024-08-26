#!/usr/bin/env bash

pwd=$(pwd)

# List of target directories
TARGET_DIRS=(
    "$pwd/08.RDS"
    "$pwd/07.docDB"
    "$pwd/03.bastion"
    "$pwd/02.load-balancer-controller"
    # "$pwd/02.external-dns"
    # "$pwd/02.cert-manager"
    # "$pwd/01.install-vpa"
    "$pwd/01.install-metrics"
    "$pwd/01.install-autoscaler"
    "$pwd/01.eks-vpc"
)

# List of commands to execute in each directory
COMMANDS=(
    "terraform init"
    "terraform refresh"
    "terraform apply -destroy -auto-approve"
)

# Loop through each directory
for TARGET_DIR in "${TARGET_DIRS[@]}"; do
    echo "Navigating to $TARGET_DIR"

    # Navigate to the target directory
    cd "$TARGET_DIR" || {
        echo "Failed to navigate to $TARGET_DIR"
        exit 1
    }

    # Initialize a command chain
    COMMAND_CHAIN=""

    # Loop through each command and build the command chain
    for COMMAND in "${COMMANDS[@]}"; do
        if [ -z "$COMMAND_CHAIN" ]; then
            COMMAND_CHAIN="$COMMAND"
        else
            COMMAND_CHAIN="$COMMAND_CHAIN && $COMMAND"
        fi
    done

    # Execute the command chain
    echo "Executing command chain: $COMMAND_CHAIN"
    eval "$COMMAND_CHAIN"

    # Check if the command chain executed successfully
    if [ $? -eq 0 ]; then
        echo "All commands executed successfully in $TARGET_DIR."
    else
        echo "Command chain failed in $TARGET_DIR."
        exit 1
    fi

    # Optional: Navigate back to the original directory (if needed)
    cd - >/dev/null || {
        echo "Failed to navigate back to $TARGET_DIR"
        exit 1
    }
done

echo "Script completed."
