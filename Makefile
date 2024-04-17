include .env
export

clean:
	rm data/deployments.json

deploy: clean
	forge script script/deploy.s.sol:DeployScript --rpc-url ${SEPOLIA_RPC_URL} --broadcast -vvv
