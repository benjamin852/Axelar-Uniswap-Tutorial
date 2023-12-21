import dotenv from 'dotenv'
import { HardhatUserConfig } from 'hardhat/config'
import '@nomicfoundation/hardhat-toolbox'
import chains from './chains.json'

dotenv.config()


const config: HardhatUserConfig = {
  solidity: '0.8.20',
  networks: {
    polygon: {
      url: chains[0].rpc,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
      chainId: chains[0].chainId,
    },
    ethereum: {
      url: chains[1].rpc,
      accounts: [`0x${process.env.PRIVATE_KEY}`],
      chainId: chains[1].chainId,
    }
  },
}

export default config
