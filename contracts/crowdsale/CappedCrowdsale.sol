pragma solidity ^0.4.11;

import '../math/SafeMath.sol';
import './Crowdsale.sol';

/**
 * @title CappedCrowdsale
 * @dev Extension of Crowsdale with a max amount of funds raised
 */
contract CappedCrowdsale is Crowdsale {
  using SafeMath for uint256;
  
  uint256 public cap;

  function CappedCrowdsale(uint256 _cap, address[] adminAddress)
    Administered(adminAddress)
  {
    require(_cap > 0);
    cap = _cap;
  }

  // overriding Crowdsale#validPurchase to add extra cap logic
  // @return true if investors can buy at the moment
  function validPurchase() internal constant returns (bool) {
    bool withinCap = tokenMinted.add(convertToToken(msg.value)) <= cap;
    return super.validPurchase() && withinCap;
  }

  // overriding Crowdsale#hasEnded to add cap logic
  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    bool capReached = tokenMinted >= cap;
    return super.hasEnded() || capReached;
  }

}
