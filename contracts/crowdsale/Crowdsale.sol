pragma solidity ^0.4.11;

import '../GoodwillCoin.sol';

import '../token/MintableToken.sol';
import '../math/SafeMath.sol';

/**
 * @title Crowdsale 
 * @dev Crowdsale is a base contract for managing a token crowdsale.
 * Crowdsales have a start and end timestamps, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate. Funds collected are forwarded to a wallet 
 * as they arrive.
 */
contract Crowdsale is Administered {
  using SafeMath for uint256;

  // The token being sold
  MintableToken public token;

  // amount of token mintedTokens
  uint256 public tokenMinted;

  // start and end timestamps where investments are allowed (both inclusive)
  uint256 public startTime;
  uint256 public endTime;

  // how many token units a buyer gets per wei
  uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;

  
  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */ 
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);


  function Crowdsale(MintableToken _token, uint256 _startTime, uint256 _endTime, uint256 _rate, uint256 _tokenMinted, address[] adminAddress) 
    Administered(adminAddress)
  {
    //require(_startTime >= now);
    require(_endTime >= _startTime);
    require(_rate > 0);
    require(admins[0] != 0x0);

    token = _token;
    startTime = _startTime;
    endTime = _endTime;
    rate = _rate;
    tokenMinted = _tokenMinted;
    
  }

  function getNow() constant returns (uint256) {
      return now;
  }
  
  function getTokensMinted() constant returns (uint256) {
      return tokenMinted;
  }
  
  function setRate(uint256 _rate) onlyAdmin returns (uint256){
        token.setRate(_rate);
        rate=_rate;
        return rate;                
  }

  function extendEndTime(uint256 _endTime) onlyAdmin returns (uint256){
        endTime = _endTime;
        return endTime;                
  }
  
  // fallback function can be used to buy tokens
  function () payable {
  
    buyTokens(msg.sender);
    
  }

  // low level token purchase function
  function buyTokens(address beneficiary) payable {
  
    require(beneficiary != 0x0);
    
    require(validPurchase());

    uint256 weiAmount = msg.value;

    // calculate token amount to be created
    uint256 tokens = convertToToken(weiAmount);
    
    // update state
    weiRaised = weiRaised.add(weiAmount);
    
    tokenMinted = tokenMinted.add(tokens);

    token.mint(beneficiary, tokens);    
    
    TokenPurchase(msg.sender, beneficiary, weiAmount, tokens);

    forwardFunds();
    
  }

  function convertToWei(uint256 amount) returns (uint256)
  {
		return amount.mul(rate);
  }

  function convertToToken(uint256 amount) returns (uint256)
  {
		return amount.div(rate);
  }

  
  // send ether to the fund collection wallet
  // override to create custom fund forwarding mechanisms
  function forwardFunds() internal {
    admins[0].transfer(msg.value);
  }

  // @return true if the transaction can buy tokens
  function validPurchase() internal constant returns (bool) {
    bool withinPeriod = now >= startTime && now <= endTime;
    bool nonZeroPurchase = msg.value != 0;
    return withinPeriod && nonZeroPurchase;
  }

  // @return true if crowdsale event has ended
  function hasEnded() public constant returns (bool) {
    return now > endTime;
  }


}
