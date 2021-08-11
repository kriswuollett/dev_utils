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

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

function wait_for_docker_container {
    while :; do
        echo Docker container [$1] waiting for running state ..
        docker inspect -f {{.State.Running}} $1 &>/dev/null && RC=$? || RC=$?
        if [[ $? -eq 0 ]]; then
            echo -e ". ${GREEN}done${NC}"
            break
        fi
        echo -n .
        sleep 1
    done
}

function wait_for_docker_container_file {
    echo -n Docker container [$1] waiting for file $2 ..
    while :; do
        docker exec -it $1 bash -c "[[ -f "$2" ]]" && RC=$? || RC=$?
        if [[ ${RC} -eq 0 ]]; then
            echo -e ". ${GREEN}done${NC}"
            break
        fi
        echo -n .
        sleep 1
    done
}

function wait_for_docker_container_port {
    echo -n Docker container [$1] waiting for port $2 ..
    while :; do
        docker exec -it $1 nc -zv localhost $2 &>/dev/null && RC=$? || RC=$?
        if [[ ${RC} -eq 0 ]]; then
            echo -e ". ${GREEN}done${NC}"
            break
        fi
        echo -n .
        sleep 1
    done
}

function set_elasticsearch_bootstrap_password {
    wait_for_docker_container_file $1 /usr/share/elasticsearch/config/elasticsearch.keystore
    echo -n "Elasticsearch [$1] initializing bootstrap password ... "
    echo -n "$2" | docker exec --interactive $1 \
        bin/elasticsearch-keystore add -x "bootstrap.password" 1>/dev/null 2>&1 &&
        echo -e "${GREEN}done${NC}" || {
        echo -e "${RED}failed${NC}"
        return 1
    }
    echo "Restarting Elasticsearch in $1 is required!"
}

function elasticsearch_add_user {
    echo -n "Elasticsearch [$1] adding user $4 with roles $6 ... "
    _ROLES="$(echo $6 | sed -e 's/\([^,]\{1,\}\)/"\1"/g')"
    docker exec -it $1 \
        curl --silent --fail --show-error -u "$2:$3" \
        -X POST "http://localhost:9200/_security/user/$4" \
        -d "{\"password\" : \"$5\", \"roles\" : [${_ROLES}] }" \
        -H "Content-Type: application/json" 1>/dev/null &&
        echo -e "${GREEN}done${NC}" || {
        echo -e "${RED}failed${NC}"
        return 1
    }
}

function elasticsearch_change_user_password {
    echo -n "Elasticsearch [$1] changing password for user $4 ... "
    docker exec -it $1 \
        curl --silent --fail --show-error -u "$2:$3" \
        -XPOST "http://localhost:9200/_security/user/$4/_password" \
        -d'{"password":"'"$5"'"}' -H "Content-Type: application/json" 1>/dev/null &&
        echo -e "${GREEN}done${NC}" || {
        echo -e "${RED}failed${NC}"
        return 1
    }
}

function elasticsearch_verify_user_password {
    echo -n "Elasticsearch [$1] verifying password for user $2 ... "
    docker exec -it $1 \
        curl --silent --fail --show-error -u "$2:$3" \
        "http://localhost:9200/_security/_authenticate" 1>/dev/null &&
        echo -e "${GREEN}done${NC}" || {
        echo -e "${RED}failed${NC}"
        return 1
    }
}
