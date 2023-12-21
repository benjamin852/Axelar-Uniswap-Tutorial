import { ethers } from 'hardhat';
import MockERC20 from '../artifacts/@openzeppelin/contracts/token/ERC20/IERC20.sol/IERC20.json';

import { getWallet } from '../utils/getWallet'
import chains from '../chains.json'

async function main() {

    const connectedWallet = getWallet(chains[0].rpc)


    const privateKey = process.env.PRIVATE_KEY;

    const gatewayMumbai = '0xBF62ef1486468a6bd26Dd669C06db43dEd5B849B'
    const gasServiceMumbai = '0xbE406F0189A0B4cf3A05C286473D23791Dd44Cc6'


    if (!privateKey) {
        throw new Error(
            "Invalid private key. Make sure the PRIVATE_KEY environment variable is set."
        );
    }

    const axlWethMumbai = '0x786D82A436EA836A8669919D605FfeaEFa51744e';

    const mockERC20 = new ethers.Contract(axlWethMumbai, MockERC20.abi, connectedWallet)

    const defiCrosschain = await ethers.deployContract('InterchainDefi',
        [gatewayMumbai, gasServiceMumbai]
    );

    await mockERC20.approve(defiCrosschain.target, 1e18.toString())

    console.log(`mumbai contract address: ${defiCrosschain.target}`);

}


main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
