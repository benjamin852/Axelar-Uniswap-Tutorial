# Interchain Defi

This contract allows you to conduct a swap with uniswap from a different blockchain. To do this we leverage Axelar's ability to send tokens and general messages.

Before interacting with the contract you must install your dependency by running `npm i`

## Deploy Contract

1. Set your private key in a .env file
2. Deploy your contract on each chain you want to interact with. This repo comes built with scripts for Ethereum Goerli and Polygon Mumbai
   - To deploy on goerli run: ` hh run scripts/deployGoerli.ts --network ethereum`
   - To deploy on mumbai run: `hh run scripts/deployMumbai.ts --network polygon`
3. In your console you should see a log returning the address of your deployed contract
   - Ex. `mumbai contract address: 0x123456789ABCDEF....`

## Interact with Contract

The quickest way to interact with the contract is via the `hardhat console`. Simply follow the following steps after deploying your contract:

1. `hh console --network polygon`
2. `const Contract = await ethers.getContractFactory("InterchainDefi")`
3. `const contract = await Contract.attach("YOUR_MUMBAI_ADDRESS")`
4. `await contract.interchainSwap("ethereum-2", "YOUR_GOERLI_ADDRESS", "axlWETH", 1000000000000000, {value: 1000000000000000})`

Once you submit the interchainSwap function you can access the transaction on the [Axelarscan Explorer]("https://testnet.axelarscan.io/") via the tx hash.
