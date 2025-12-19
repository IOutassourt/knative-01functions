#!/bin/bash

# Run the build_and_test workflow
# circleci local execute <job-name>
# config: ./.circleci/config.yml
circleci local execute test
