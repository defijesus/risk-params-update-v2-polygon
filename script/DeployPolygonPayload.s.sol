// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from 'forge-std/Script.sol';
import {ProposalPayload} from '../src/contracts/polygon/ProposalPayload.sol';

contract DeployPolygonPayload is Script {
  function run() external {
    vm.startBroadcast();
    new ProposalPayload();
    vm.stopBroadcast();
  }
}
