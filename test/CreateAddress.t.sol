// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import { Test, console } from "forge-std/Test.sol";
import { Empty } from "../contracts/Empty.sol";

contract CreateAddressTest is Test {
    /// @dev keccak256("zksyncCreate")
    bytes32 constant CREATE_PREFIX = 0x63bae3a9951d38e8a3fbb7b70909afc1200610fc5bc55ade242f815974674f23;
    bytes32 internal constant ZKSYNC_PROFILE_HASH = keccak256(abi.encodePacked("zksync"));
    bool internal isZkSync;

    function setUp() public {
        bytes32 profileHash = keccak256(abi.encodePacked(vm.envString("FOUNDRY_PROFILE")));
        if (profileHash == ZKSYNC_PROFILE_HASH) isZkSync = true;
    }

    function predictAddress(address sender, uint256 nonce) public pure returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(
            bytes1(0xd6), bytes1(0x94), sender, bytes1(uint8(nonce))
        ));
        return address(uint160(uint256(hash)));
    }

    // Implementation of the address calculation for the zksync system contracts. 
    // It is moved from lib because dependency requires to change contract source in library before compile project:
    // sed -i '' 's/{{SYSTEM_CONTRACTS_OFFSET}}/32768/g' lib/era-contracts/system-contracts/contracts/Constants.sol
    //
    // era-contracts/system-contracts/contracts/ContractDeployer.sol -> getNewAddressCreate
    // https://github.com/matter-labs/era-contracts/blob/6892ccc93bfbc36686809fd80d20fa6afabfc169/system-contracts/contracts/ContractDeployer.sol#L116
    function predictAddressZkSync(address sender, uint256 nonce) public pure returns (address) {
        bytes32 hash = keccak256(
            bytes.concat(CREATE_PREFIX, bytes32(uint256(uint160(sender))), bytes32(nonce))
        );
        return address(uint160(uint256(hash)));
    }

    function test_Create() public {
        console.log("create address in zkevm", predictAddressZkSync(address(this), 1));
        console.log("create address in evm", predictAddress(address(this), 1));
        
        if (isZkSync) {
            assert(predictAddressZkSync(address(this), 1) == address(new Empty()));
        } else {
            console.log(predictAddress(address(this), 1));
            assert(predictAddress(address(this), 1) == address(new Empty()));
        }
    }
}

