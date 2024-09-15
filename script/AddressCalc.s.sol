// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.23;

import {Script, console} from "forge-std/Script.sol";

contract AddressCalcScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        // ...

        vm.stopBroadcast();
    }
}
