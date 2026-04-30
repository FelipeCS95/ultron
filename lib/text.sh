#!/bin/bash

ultron::uppercase() {
  echo "$1" | tr '[:lower:]' '[:upper:]'
}

ultron::lowercase() {
  echo "$1" | tr '[:upper:]' '[:lower:]'
}

ultron::normalize_project_name() {
  ultron::lowercase "$1" | sed 's/[^a-zA-Z0-9]/_/g'
}
