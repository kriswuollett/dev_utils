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

declare -a ADJECTIVES=(able above absolute accepted accurate ace active actual adapted adapting adequate adjusted advanced alert alive allowed allowing amazed amazing ample amused amusing apparent apt arriving arrogant artistic assured assuring awaited awake aware balanced becoming beloved better big blessed bold boss brave brainy brief bright bursting busy calm capable capital careful caring casual causal central certain champion charmed charming cheerful chief choice civil classic clean clear clever climbing close closing coherent comic communal complete composed concise concrete content cool correct cosmic crack creative credible crisp crucial cuddly cunning curious current cute daring darling dashing dear decent deciding deep definite delicate desired destined devoted direct discrete distinct diverse divine dominant driven driving dynamic eager easy electric elegant emerging eminent enabled enabling endless engaged engaging enhanced enjoyed enormous enough epic equal equipped eternal ethical evident evolved evolving exact excited exciting exotic expert factual fair faithful famous fancy fast feasible fine finer firm first fit fitting fleet flexible flowing fluent flying fond frank free fresh full fun funky funny game generous gentle genuine giving glad gleaming glorious glowing golden good gorgeous grand grateful great growing grown guided guiding handy happy hardy harmless healthy helped helpful helping heroic hip holy honest hopeful hot huge humane humble humorous ideal immense immortal immune improved in included infinite informed innocent inspired integral intense intent internal intimate inviting joint just keen key kind knowing known large lasting leading learning legal legible lenient liberal light liked literate live living logical loved loving loyal lucky magical magnetic main major many massive master mature maximum measured meet merry mighty mint model modern modest moral more moved moving musical mutual national native natural nearby neat needed neutral new next nice noble normal notable noted novel obliging on one open optimal optimum organic oriented outgoing patient peaceful perfect pet picked pleasant pleased pleasing poetic polished polite popular positive possible powerful precious precise premium prepared present pretty primary prime pro probable profound promoted prompt proper proud proven pumped pure quality quick quiet rapid rare rational ready real refined regular related relative relaxed relaxing relevant relieved renewed renewing resolved rested rich right robust romantic ruling sacred safe saved saving secure select selected sensible set settled settling sharing sharp shining simple sincere singular skilled smart smashing smiling smooth social solid sought sound special splendid square stable star steady sterling still stirred stirring striking strong stunning subtle suitable suited summary sunny super superb supreme sure sweeping sweet talented teaching tender thankful thorough tidy tight together tolerant top topical tops touched touching tough true trusted trusting trusty ultimate unbiased uncommon unified unique united up upright upward usable useful valid valued vast verified viable vital vocal wanted warm wealthy welcome welcomed well whole willing winning wired wise witty wondrous workable working worthy)

declare -a ANIMALS=(aardvark adder airedale akita albacore alien alpaca amoeba anchovy anemone ant anteater antelope ape aphid arachnid asp baboon badger barnacle basilisk bass bat beagle bear bedbug bee beetle bengal bird bison blowfish bluebird bluegill bluejay boa boar bobcat bonefish boxer bream buck buffalo bug bull bulldog bullfrog bunny burro buzzard caiman calf camel cardinal caribou cat catfish cattle chamois cheetah chicken chigger chimp chipmunk chow cicada civet clam cobra cockatoo cod collie colt condor coral corgi cougar cow cowbird coyote crab crane crappie crawdad crayfish cricket crow cub dane dassie deer dingo dinosaur doberman dodo doe dog dogfish dolphin donkey dory dove dragon dragonfly drake drum duck duckling eagle earwig eel eft egret elephant elf elk emu escargot ewe falcon fawn feline ferret filly finch firefly fish flamingo flea flounder fly foal fowl fox foxhound frog gannet gar garfish gator gazelle gecko gelding ghost ghoul gibbon giraffe glider glowworm gnat gnu goat gobbler goblin goldfish goose gopher gorilla goshawk grackle griffon grizzly grouper grouse grub grubworm guinea gull guppy haddock hagfish halibut hamster hare hawk hedgehog hen hermit heron herring hippo hog honeybee hookworm hornet horse hound humpback husky hyena hyrax ibex iguana imp impala insect jackal jackass jaguar javelin jawfish jay jaybird jennet joey kangaroo katydid kid killdeer kingfish kit kite kitten kiwi koala kodiak koi krill lab labrador lacewing ladybird ladybug lamb lamprey lark leech lemming lemur leopard liger lion lioness lionfish lizard llama lobster locust longhorn loon lorid louse lynx lyrebird macaque macaw mackerel maggot magpie mako malamute mallard mammal mammoth man manatee mantis marlin marmoset marmot marten martin mastiff mastodon mayfly meerkat midge mink minnow mite moccasin mole mollusk molly monarch mongoose mongrel monitor monkey monkfish monster moose moray mosquito moth mouse mudfish mule mullet muskox muskrat mustang mutt narwhal newt oarfish ocelot octopus opossum orca oriole oryx osprey ostrich owl ox oyster panda pangolin panther parakeet parrot peacock pegasus pelican penguin perch pheasant phoenix pig pigeon piglet pika pipefish piranha platypus polecat polliwog pony poodle porpoise possum prawn primate pug puma pup python quagga quail quetzal rabbit raccoon racer ram raptor rat rattler raven ray redbird redfish reindeer reptile rhino ringtail robin rodent rooster roughy sailfish salmon satyr sawfish sawfly scorpion sculpin seagull seahorse seal seasnail serval shad shark sheep sheepdog shepherd shiner shrew shrimp silkworm skink skunk skylark sloth slug snail snake snapper snipe sole spaniel sparrow spider sponge squid squirrel stag stallion starfish starling stingray stinkbug stork stud sturgeon sunbeam sunbird sunfish swan swift swine tadpole tahr tapir tarpon teal termite terrapin terrier tetra thrush tick tiger titmouse toad tomcat tortoise toucan treefrog troll trout tuna turkey turtle unicorn urchin vervet viper vulture wahoo wallaby walleye walrus warthog wasp weasel weevil werewolf whale whippet wildcat wolf wombat woodcock worm wren yak yeti zebra)

_ENV_FILE=".env"
_ENV_VARS_BUILD_PATH=".env.variables"
_ENV_SECRETS_BUILD_PATH=".env.secrets"
_EXISTING_SECRETS_PATH=".secrets"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
_CACHE_PATH=".cache"

# If LOCAL_WORKSPACE_FOLDER is set, we are running in vscode dev container.
# If not, then _WORKSPACE_PATH to Docker bind mounts should be relative.
_WORKSPACE_PATH="${LOCAL_WORKSPACE_FOLDER}/"
if [[ "x${_WORKSPACE_PATH}" == "x/" ]]; then
    _WORKSPACE_PATH=""
fi

function init_dirs {
    touch "./${_ENV_FILE}"
    mkdir -p "./${_ENV_VARS_BUILD_PATH}" "./${_ENV_SECRETS_BUILD_PATH}"

    # If LOCAL_WORKSPACE_FOLDER is set, we are running in a vscode dev
    # container. In that case create a symlink to /workspace so that
    # Docker does not complain about missing secret files.
    if [[ "${LOCAL_WORKSPACE_FOLDER}x" != "x" ]]; then
        if [[ ! -d "$(dirname ${LOCAL_WORKSPACE_FOLDER})" ]]; then
            sudo mkdir -p "$(dirname ${LOCAL_WORKSPACE_FOLDER})"
            sudo ln -sf "/workspaces/$(basename ${LOCAL_WORKSPACE_FOLDER})" "${LOCAL_WORKSPACE_FOLDER}"
        fi
    fi
}

function build_env {
    rm -f "./${_ENV_FILE}"
    for env_file in "./${_ENV_VARS_BUILD_PATH}/"*; do
        filename=$(basename ${env_file})
        echo "${filename}=$(<${env_file})" >>.env
    done
    for secret_file in "./${_ENV_SECRETS_BUILD_PATH}/"*; do
        filename=$(basename ${secret_file})
        echo "${filename}_FILE=/run/secrets/${filename}" >>.env
        echo "${filename}_WORKSPACE_FILE=${_WORKSPACE_PATH}.env.secrets/${filename}" >>.env
    done
    sort -k 1 -t = -o .env .env
}

function clear_env {
    rm -f "./${_ENV_FILE}"
    rm -rf "./${_ENV_VARS_BUILD_PATH}"
    rm -rf "./${_ENV_SECRETS_BUILD_PATH}"
}

function add_env {
    echo -n "$2" >"./${_ENV_VARS_BUILD_PATH}/$1"
    export "$1=$2"
}

# Makes both a regular variable as well as a file with the secret contents.
# The variable version is useful when a container image doesn't support a
# *_FILE version of environment variables. This method should not be used
# when the secret content is not "text".
#
# Does not regenerate the secret if .env.secrets/$1 already exists which
# prevents issues when rebuilding locally.
function add_secret_text {
    if [[ ! -f "./${_ENV_SECRETS_BUILD_PATH}/$1" ]]; then
        echo -n "$2" >"./${_ENV_SECRETS_BUILD_PATH}/$1"
    fi
    add_env "$1" "$2"
}

function fetch_file {
    URL="$2"
    FILENAME="$(echo ${URL} | grep / | cut -d/ -f3-)"
    CACHED_FILE=${_CACHE_PATH}/${FILENAME}
    if [[ ! -f "${CACHED_FILE}" ]]; then
        echo -n "Fetching ${URL} ... "
        wget -P ${_CACHE_PATH} -x ${URL} 1>/dev/null &&
            echo -e "${GREEN}done${NC}" || {
            echo -e "${RED}failed${NC}"
            return 1
        }
        add_env "$1_WORKSPACE_FILE" "${CACHED_FILE}"
    else
        echo "File ${URL} already cached. "
    fi
}

function map_existing_secret_text {
    if [[ ! -f "./${_EXISTING_SECRETS_PATH}/$1" ]]; then
        echo "Existing secret file not found at ${_EXISTING_SECRETS_PATH}/$1."
        echo "Update following command as needed, and run:"
        echo
        echo "echo -n \"[secret text]\" > ${_EXISTING_SECRETS_PATH}/$1"
        exit 1
    fi
    add_secret_text $2 $(<"${_EXISTING_SECRETS_PATH}/$1")
}

function generate_password {
    add_secret_text $1 "${ADJECTIVES[$(($RANDOM % ${#ADJECTIVES[@]}))]}-${ANIMALS[$(($RANDOM % ${#ANIMALS[@]}))]}"
}
