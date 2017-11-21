import "./admin/Administered.sol";
import "./ConvertLib.sol";
import "./GoodwillCoin.sol";


pragma solidity ^0.4.11; //We have to specify what version of the compiler this code will use

contract RSLogistics is Administered {
  using ConvertLib for *;
  
  GoodwillCoin rsToken;
  
  function RSLogistics(GoodwillCoin _rsToken, address[] adminAddress) 
      Administered(adminAddress)
  {
  
    rsToken=_rsToken;
    
  }
  
  function RequestDelivery(address rsAddress, bytes32 rsType, uint _rsToken) returns (bool) {
      return true;
      
  }
  
  function ConfirmDelivery(address rsAddress, bytes32 rsType, uint _rsToken) returns (bool) {
      return true;
      
  }

  function DeliveryStatus(address rsAddress) returns (bool) {
      return true;
  }
  
}