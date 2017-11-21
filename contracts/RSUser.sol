import "./ConvertLib.sol";
import "./GoodwillCoin.sol";
import "./RSNetwork.sol";
pragma solidity ^0.4.11; //We have to specify what version of the compiler this code will use

contract RSUser {

  using ConvertLib for *;
  
  GoodwillCoin rsToken;
  RSNetwork rsNetwork;
  
  function RSUser(GoodwillCoin _rsToken, RSNetwork _rsNetwork) {
      rsToken=_rsToken;
      rsNetwork=_rsNetwork;
  }

  function RequestUse(address rsAddress, bytes32 rsType, uint _rsToken) {
      
  }
  
  function GetUsage(address rsAdress) {
  }
  



}                                                                                                                               