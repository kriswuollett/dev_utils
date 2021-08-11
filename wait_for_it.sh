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
        echo Waiting for Docker container $1 ..
        docker inspect -f {{.State.Running}} $1 &>/dev/null && RC=$? || RC=$?
        if [[ $? -eq 0 ]]; then
            echo -e ". ${GREEN}done${NC}!"
            break
        fi
        echo -n .
        sleep 1
    done
}

function wait_for_docker_container_file {
    echo -n Waiting for Docker container $1 file $2 ..
    while :; do
        docker exec -it $1 bash -c "[[ -f "$2" ]]" && RC=$? || RC=$?
        if [[ ${RC} -eq 0 ]]; then
            echo -e ". ${GREEN}done${NC}!"
            break
        fi
        echo -n .
        sleep 1
    done
}

function wait_for_docker_container_port {
    echo -n Waiting for Docker container $1 port $2 ..
    while :; do
        docker exec -it $1 nc -zv localhost $2 &>/dev/null && RC=$? || RC=$?
        if [[ ${RC} -eq 0 ]]; then
            echo -e ". ${GREEN}done${NC}!"
            break
        fi
        echo -n .
        sleep 1
    done
}
