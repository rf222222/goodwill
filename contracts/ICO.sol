pragma solidity ^0.4.11;

import "./crowdsale/CappedCrowdsale.sol";
import "./crowdsale/Crowdsale.sol";
import "./token/MintableToken.sol";
import "./GoodwillCoin.sol";

/**
 * @title Goodwill Coins ICO
 * @dev 
 * The way to add new features to a base crowdsale is by multiple inheritance.
 * In this example we are providing following extensions:
 * CappedCrowdsale - sets a max boundary for raised funds
 *
 * After adding multiple features it's good practice to run integration tests
 * to ensure that subcontracts works together as intended.
 */
contract ICO is CappedCrowdsale {

  function ICO(MintableToken _token, uint256 _startTime, uint256 _endTime, uint256 _rate, uint256 _cap, uint256 _mintedTokens, address[] adminAddress)
    Administered(adminAddress)
    CappedCrowdsale(_cap, adminAddress)
    Crowdsale(_token, _startTime, _endTime, _rate, _mintedTokens, adminAddress)
  {
    
  }

}