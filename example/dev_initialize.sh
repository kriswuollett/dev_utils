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

source ../wait_for_it.sh

echo "Bringing up development database_initialization stack ..."
docker-compose --profile database_initialization up -d --build
wait_for_docker_container_port db1 5432
docker-compose run db1-migrations
docker-compose --profile development up -d --build
wait_for_docker_container_port backend 8080

echo -n "Verifying that backend is ready ... "
docker exec -it backend \
    curl --silent --fail --show-error -u "kris:$(<.secrets/backend_kris_password)" \
    "http://localhost:8080/_healthcheck" 1>/dev/null &&
    echo -e "${GREEN}done${NC}" || {
    echo -e "${RED}failed${NC}"
    return 1
}
