include .env
export

clean:
	rm data/deployments.json

deploy:
	forge script script/deploy.s.sol:DeployScript --rpc-url ${SEPOLIA_RPC_URL} --broadcast -vvv

test-faucet:
	bun script/mint_and_use_faucet.ts
