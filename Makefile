# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

# deps
update:; forge update

# Build & test
build  :; forge build --sizes

test   :; forge test -vvv

# Deploy L2 Polygon proposal payloads
deploy-payload :; forge script script/DeployPolygonPayload.s.sol:DeployPolygonPayload --rpc-url ${RPC_POLYGON} --broadcast --ledger --sender ${LEDGER_SENDER} --verify --etherscan-api-key ${ETHERSCAN_API_KEY} -vvvv

# Deploy L1 proposal polygon
deploy-l1-payload-proposal :; forge script script/DeployL1PolygonProposal.s.sol:DeployPayload --rpc-url ${RPC_URL} --broadcast --private-key ${PRIVATE_KEY} -vvvv
