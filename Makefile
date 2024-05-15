include .env
export

clean:
	rm data/deployments.json

deploy:
	forge script script/deploy.s.sol:DeployScript --rpc-url ${SEPOLIA_RPC_URL} --broadcast -vvv

test:
	forge test
deploy-hardhat:
	npx hardhat run script/deploy.ts --network ${HARDHAT_NETWORK}

upgrade-hardhat:
	npx hardhat run script/upgrade_faucet.ts --network ${HARDHAT_NETWORK}

test-faucet:
	bun script/mint_and_use_faucet.ts
