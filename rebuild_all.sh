#!/bin/bash

set -e

helm lint helm-chart-sources/*
helm package helm-chart-sources/*

helm repo index --url https://jameseck.github.io/helm-charts/ .
