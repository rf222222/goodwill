import "./admin/Administered.sol";
import "./ConvertLib.sol";
import "./GoodwillCoin.sol";

pragma solidity ^0.4.11; //We have to specify what version of the compiler this code will use

contract RSOperator is Administered {
  using ConvertLib for *;
  
  GoodwillCoin rsToken;  
  
  function RSOperator( GoodwillCoin _rsToken, address[] adminAddress) 
      Administered(adminAddress)
  {
  
    rsToken=_rsToken;
    
  }

  function SetResourceTerm(bytes32 _rsName, bytes32 _rsType, uint _rsToken)
  {
  
      //rsNetwork.SetResourceTerm(_rsName,  _rsType, _rsToken);
  
  }

}