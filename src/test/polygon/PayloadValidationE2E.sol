// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import 'forge-std/Test.sol';
import {AaveV2Polygon} from 'aave-address-book/AaveAddressBook.sol';
import {GovHelpers} from 'aave-helpers/GovHelpers.sol';
import {ProtocolV3TestBase, ReserveConfig, ReserveTokens, IERC20} from 'aave-helpers/ProtocolV3TestBase.sol';
import {BridgeExecutorHelpers} from 'aave-helpers/BridgeExecutorHelpers.sol';
import {AaveGovernanceV2, IExecutorWithTimelock} from 'aave-address-book/AaveGovernanceV2.sol';
import {IStateReceiver} from 'governance-crosschain-bridges/contracts/dependencies/polygon/fxportal/FxChild.sol';
import {CrosschainForwarderPolygon} from '../../contracts/polygon/CrosschainForwarderPolygon.sol';
import {ProposalPayload} from '../../contracts/polygon/ProposalPayload.sol';
import {DeployL1PolygonProposal} from '../../../script/DeployL1PolygonProposal.s.sol';

contract PolygonPayloadE2ETest is ProtocolV3TestBase {
  // the identifiers of the forks
  uint256 mainnetFork;
  uint256 polygonFork;

  ProposalPayload public proposalPayload;

  address public constant CROSSCHAIN_FORWARDER_POLYGON =
    0x158a6bC04F0828318821baE797f50B0A1299d45b;
  address public constant BRIDGE_ADMIN =
    0x0000000000000000000000000000000000001001;
  address public constant FX_CHILD_ADDRESS =
    0x8397259c983751DAf40400790063935a11afa28a;
  address public constant POLYGON_BRIDGE_EXECUTOR =
    0xdc9A35B16DB4e126cFeDC41322b3a36454B1F772;

  address public constant MIMATIC = 0xa3Fa99A148fA48D14Ed51d610c367C61876997F1;

  address public constant DAI = 0x8f3Cf7ad23Cd3CaDbD9735AFf958023239c6A063;

  function setUp() public {
    polygonFork = vm.createFork(vm.rpcUrl('polygon'));
    mainnetFork = vm.createFork(vm.rpcUrl('ethereum'));
  }

  // utility to transform memory to calldata so array range access is available
  function _cutBytes(bytes calldata input)
    public
    pure
    returns (bytes calldata)
  {
    return input[64:];
  }

  function testProposalE2E() public {
    vm.selectFork(polygonFork);

    // 1. use deployed l2 payload
    proposalPayload = ProposalPayload(0xFACe5FAfB0b61F77a67D239b3d1c94f08536db62);

    // 2. create l1 proposal
    vm.selectFork(mainnetFork);
    vm.startPrank(GovHelpers.AAVE_WHALE);
    uint256 proposalId = DeployL1PolygonProposal._deployL1Proposal(
      address(proposalPayload),
      0xdff78c5c3bbca49817d979701bb606c9779f290360755dd451d8e78c2f4444d0
    );
    vm.stopPrank();

    // 3. execute proposal and record logs so we can extract the emitted StateSynced event
    vm.recordLogs();
    GovHelpers.passVoteAndExecute(vm, proposalId);

    Vm.Log[] memory entries = vm.getRecordedLogs();
    assertEq(
      keccak256('StateSynced(uint256,address,bytes)'),
      entries[2].topics[0]
    );
    assertEq(address(uint160(uint256(entries[2].topics[2]))), FX_CHILD_ADDRESS);

    // 4. mock the receive on l2 with the data emitted on StateSynced
    vm.selectFork(polygonFork);
    vm.startPrank(BRIDGE_ADMIN);
    IStateReceiver(FX_CHILD_ADDRESS).onStateReceive(
      uint256(entries[2].topics[1]),
      this._cutBytes(entries[2].data)
    );
    vm.stopPrank();

    // 5. Forward time & execute proposal
    BridgeExecutorHelpers.waitAndExecuteLatest(vm, POLYGON_BRIDGE_EXECUTOR);

    // 6. verify results
    /// BAL
    (, , , , , , , , , bool balFrozen) = AaveV2Polygon
      .AAVE_PROTOCOL_DATA_PROVIDER
      .getReserveConfigurationData(proposalPayload.BAL());
    assertTrue(balFrozen);

    /// CRV
    (, , , , , , bool crvBorrowingEnabled, , , bool crvFrozen) = AaveV2Polygon
      .AAVE_PROTOCOL_DATA_PROVIDER
      .getReserveConfigurationData(proposalPayload.CRV());
    assertFalse(crvFrozen);
    assertFalse(crvBorrowingEnabled);

    /// GHST
    (, , , , , , , , , bool ghstFrozen) = AaveV2Polygon
      .AAVE_PROTOCOL_DATA_PROVIDER
      .getReserveConfigurationData(proposalPayload.GHST());
    assertTrue(ghstFrozen);

    /// LINK
    (, , , , , , bool linkBorrowingEnabled, , , bool linkFrozen) = AaveV2Polygon
      .AAVE_PROTOCOL_DATA_PROVIDER
      .getReserveConfigurationData(proposalPayload.LINK());
    assertFalse(linkFrozen);
    assertFalse(linkBorrowingEnabled);

    /// SUSHI
    (, , , , , , , , , bool sushiFrozen) = AaveV2Polygon
      .AAVE_PROTOCOL_DATA_PROVIDER
      .getReserveConfigurationData(proposalPayload.SUSHI());
    assertTrue(sushiFrozen);

    /// DPI
    (, , , , , , bool dpiBorrowingEnabled, , , bool dpiFrozen) = AaveV2Polygon
      .AAVE_PROTOCOL_DATA_PROVIDER
      .getReserveConfigurationData(proposalPayload.DPI());
    assertFalse(dpiFrozen);
    assertFalse(dpiBorrowingEnabled);
  }
}
