#!/usr/bin/env bash

if [ -z "$1" ]; then
    echo "Usage: ./new_project.sh <ProjectName>"
    exit 1
fi

PROJECT_NAME=$1
TEMPLATE_DIR=$(dirname "$0")

mkdir "$PROJECT_NAME"
cp -r "$TEMPLATE_DIR"/* "$PROJECT_NAME"

rm "$PROJECT_NAME/new_project.sh"
rm "$PROJECT_NAME/new_project.ps1"

# Replace old name with new project name
find "$PROJECT_NAME" -type f -exec sed -i "s/brawui/${PROJECT_NAME}/g" {} +

echo "Created new project: $PROJECT_NAME"
