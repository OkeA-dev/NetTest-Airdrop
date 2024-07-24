//SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {NetTest__Token} from "../src/NetTestToken.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract DeployMerkleAirdrop is Script {
     bytes32 private s_merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
     uint256 private s_amountToTransfer = 4 * 25 * 1e18;

    function deployMerkleAirdrop() public returns(MerkleAirdrop, NetTest__Token) {
         vm.startBroadcast();
        NetTest__Token token = new NetTest__Token();
        MerkleAirdrop airdrop = new MerkleAirdrop(s_merkleRoot, IERC20(address(token)));
        token.mint(token.owner(), s_amountToTransfer);
        token.transfer(address(airdrop), s_amountToTransfer);
        vm.stopBroadcast();

        return (airdrop, token);
    }

    function run() external returns (MerkleAirdrop, NetTest__Token) {
       return deployMerkleAirdrop();
    }
}