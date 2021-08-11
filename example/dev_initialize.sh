#!/usr/bin/env bash
#
#  Copyright 2021 Kristopher Wuollett
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

set -e

source ../docker_helper.sh

echo "Bringing up development database_initialization stack ..."
docker-compose --profile database_initialization up -d --build
wait_for_docker_container_port db1 5432
docker-compose run db1-migrations

set_elasticsearch_bootstrap_password es1 $(<.secrets/elastic_bootstrap_password)
docker-compose --profile database_initialization restart
wait_for_docker_container_port es1 9200

elasticsearch_change_user_password es1 \
    elastic $(<.secrets/elastic_bootstrap_password) \
    elastic $(<.secrets/elastic_password)
elasticsearch_add_user es1 \
    elastic $(<.secrets/elastic_password) \
    www_viewer $(<.secrets/elastic_www_viewer_password) \
    viewer

elasticsearch_verify_user_password es1 \
    elastic $(<.secrets/elastic_password)
elasticsearch_verify_user_password es1 \
    www_viewer $(<.secrets/elastic_www_viewer_password)

echo "Bringing up development full stack ..."
docker-compose --profile full up -d --build
wait_for_docker_container_port backend 8080
