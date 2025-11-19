#!/usr/bin/env bash

cd apps/frontend/youtube-live-app
npm i
npm run build
aws s3 sync ./dist s3://lhuckazdevops.click
