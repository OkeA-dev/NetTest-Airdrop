//SPDX-License-Identifier: MIT

// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)\
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {NetTest__Token} from "../src/NetTestToken.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";

contract MerkleAirdropTest is Test, ZkSyncChainChecker {
    uint256 private constant AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 private constant AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;
    bytes32 private constant ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    address public gasPayer;
    address user;
    uint256 privateKey;

    MerkleAirdrop airdrop;
    NetTest__Token token;
    bytes32 proofOne = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32 proofTwo = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32[] public PROOF = [proofTwo, proofOne];

    function setUp() public {
        if (!isZkSyncChain()) {
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.run();
        } else {
            token = new NetTest__Token();
            airdrop = new MerkleAirdrop(ROOT, token);
            token.mint(token.owner(), AMOUNT_TO_SEND);
            token.transfer(address(airdrop), AMOUNT_TO_SEND);
        }

        (user, privateKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    /////////////////////////////
    ///     CLAIMING TEST     //
    ///////////////////////////
    function testUsersCanClaim() public {
        uint256 userStartingBalance = token.balanceOf(user);
        bytes32 digest = airdrop.getMessage(user, AMOUNT_TO_CLAIM);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(privateKey, digest);

        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);

        uint256 userEndingBalance = token.balanceOf(user);
        console.log(userEndingBalance);
        assertEq(userEndingBalance - userStartingBalance, AMOUNT_TO_CLAIM);
    }
}
