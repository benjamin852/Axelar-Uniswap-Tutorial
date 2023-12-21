// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import {AxelarExecutable} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/executable/AxelarExecutable.sol";
import {IAxelarGateway} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGateway.sol";
import {IAxelarGasService} from "@axelar-network/axelar-gmp-sdk-solidity/contracts/interfaces/IAxelarGasService.sol";

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

contract InterchainDefi is AxelarExecutable {
    address public wethGoerli = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
    address public uniGoerli = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;

    IAxelarGasService public immutable gasService;

    // goerli router
    ISwapRouter public immutable swapRouter =
        ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);

    constructor(
        address _gateway,
        address _gasService
    ) AxelarExecutable(_gateway) {
        gasService = IAxelarGasService(_gasService);
    }

    function interchainSwap(
        string memory _destChain,
        string memory _destContractAddr,
        string memory _symbol,
        uint256 _amount
    ) external payable {
        require(msg.value > 0, "Gas payment required");

        uint24 poolFee = 3000;

        address tokenAddress = gateway.tokenAddresses(_symbol);

        IERC20(tokenAddress).transferFrom(msg.sender, address(this), _amount);
        IERC20(tokenAddress).approve(address(gateway), _amount);

        ISwapRouter.ExactInputSingleParams memory swapParams = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: wethGoerli,
                tokenOut: uniGoerli,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp + 1 days,
                amountIn: _amount,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        bytes memory encodedSwapPayload = abi.encode(swapParams);

        gasService.payNativeGasForContractCallWithToken{value: msg.value}(
            address(this),
            _destChain,
            _destContractAddr,
            encodedSwapPayload,
            _symbol,
            _amount,
            msg.sender
        );

        gateway.callContractWithToken(
            _destChain,
            _destContractAddr,
            encodedSwapPayload,
            _symbol,
            _amount
        );
    }

    function _executeWithToken(
        string calldata,
        string calldata,
        bytes calldata _payload,
        string calldata _tokenSymbol,
        uint256 _amount
    ) internal override {
        ISwapRouter.ExactInputSingleParams memory decodedGmpMessage = abi
            .decode(_payload, (ISwapRouter.ExactInputSingleParams));

        IERC20(wethGoerli).approve(address(swapRouter), _amount);

        swapRouter.exactInputSingle(decodedGmpMessage);
    }
}
