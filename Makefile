-include .env

.PHONY: all test clean deploy fund help install snapshot format anvil 

DEFAULT_ANVIL_KEY := 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
RPC_URL=http://127.0.0.1:8545

# Clean the repo
clean  :; forge clean

# Remove modules
remove :; rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"

install :; forge install cyfrin/foundry-devops@0.2.2 --no-commit && forge install smartcontractkit/chainlink-brownie-contracts@1.1.1 --no-commit && forge install foundry-rs/forge-std@v1.8.2 --no-commit && forge install transmissions11/solmate@v6 --no-commit

# Update Dependencies
update:; forge update

build:; forge build

all: clean remove install update build

test :; forge test 

snapshot :; forge snapshot

format :; forge fmt

deploy-anvil:
	@forge script script/DeployLottery.s.sol:DeployLottery --rpc-url $(RPC_URL) --private-key $(DEFAULT_ANVIL_KEY)

deploy-sepolia:
	@forge script script/DeployLottery.s.sol:DeployLottery --rpc-url $(SEPOLIA_RPC_URL)
	--account  default --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

# Replace <Contract_ADDRESS> with the address Anvil gives you after you deploy the contract to it.
# Replace <AMOUNT_IN_WEI> with some wei for example 1 ether = 1e18 wei
# Some varriables such as SEPOLIA_RPC_URL or ETHERSCAN_API_KEY are in .env file. Replace them with your owns
# Commands
enter-lottery: cast send <CONTRACT_ADDRESS> "enterLottery()" --value <AMOUNT_IN_WEI> --rpc-url $(RPC_URL) --private-key $(DEFAULT_ANVIL_KEY)

# checkUpkeep and performUpkeep are supposed to be called automatically from the Chainlink nodes
# fulfillRandomWords might not work as well, since it is supposed to be called by VRFCoordinator contract
# these functions might not work on local Ethereum node

# getters
entrance-price: cast call <CONTRACT_ADDRESS> "getEntrancePrice()" --rpc-url $(RPC_URL)

lottery-state: cast call <CONTRACT_ADDRESS> "getLotteryState()" --rpc-url $(RPC_URL)

recent-winner: cast call <CONTRACT_ADDRESS> "getRecentWinner()" --rpc-url $(RPC_URL)

last-time-winner-picked: cast call <CONTRACT_ADDRESS> "getLastTimeWinnerPicked()" --rpc-url $(RPC_URL)

participants: cast call <CONTRACT_ADDRESS> "getParticipants()" --rpc-url $(RPC_URL)