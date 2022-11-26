// SPDX-License-Identifier: AGPL-3.0-only

/*
   _      ΞΞΞΞ      _
  /_;-.__ / _\  _.-;_\
     `-._`'`_/'`.-'
         `\   /`
          |  /
         /-.(
         \_._\
          \ \`;
           > |/
          / //
          |//
          \(\
           ``
     defijesus.eth
*/

pragma solidity ^0.8.15;

import {AaveV2Polygon} from "aave-address-book/AaveV2Polygon.sol";

/**
 * @title Risk Parameter Updates for Aave v2 Polygon
 * @author Llamaxyz & Chaos Labs (defijesus, Matthew Graham, Omer Arie Goldberg, Yonatan Haimowitz)
 * @notice Update Polygon v2 Risk Parameters
 * Governance Forum Post: https://governance.aave.com/t/arc-risk-parameter-recommendations-for-aave-v2-polygon-2022-11-25/10826
 * Snapshot: N/A 
 */
contract ProposalPayload {

    address public constant BAL = 0x9a71012B13CA4d3D0Cdc72A177DF3ef03b0E76A3;
    address public constant CRV = 0x172370d5Cd63279eFa6d502DAB29171933a610AF;
    address public constant GHST = 0x385Eeac5cB85A38A9a07A70c73e0a3271CfB54A7;
    address public constant LINK = 0x53E0bca35eC356BD5ddDFebbD1Fc0fD03FaBad39;
    address public constant SUSHI = 0x0b3F868E0BE5597D5DB7fEB59E1CADBb0fdDa50a;
    address public constant DPI = 0x85955046DF4668e1DD369D2DE9f3AEB98DD2A369;

    /// @notice The AAVE governance executor calls this function to implement the proposal.
    function execute() external {
        /// unfreezing a reserve when its not frozen is a noop  
        /// freezing an already frozen reserve is a noop
        /// disabling borrowing on a reserve when its already disabled is a noop
        
        AaveV2Polygon.POOL_CONFIGURATOR.freezeReserve(BAL);

        AaveV2Polygon.POOL_CONFIGURATOR.unfreezeReserve(CRV);
        AaveV2Polygon.POOL_CONFIGURATOR.disableBorrowingOnReserve(CRV);

        AaveV2Polygon.POOL_CONFIGURATOR.freezeReserve(GHST);

        AaveV2Polygon.POOL_CONFIGURATOR.unfreezeReserve(LINK);
        AaveV2Polygon.POOL_CONFIGURATOR.disableBorrowingOnReserve(LINK);

        AaveV2Polygon.POOL_CONFIGURATOR.freezeReserve(SUSHI);

        AaveV2Polygon.POOL_CONFIGURATOR.unfreezeReserve(DPI);
        AaveV2Polygon.POOL_CONFIGURATOR.disableBorrowingOnReserve(DPI);
    }
}
