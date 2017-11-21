import "./admin/Administered.sol";
import "./ConvertLib.sol";
import "./GoodwillCoin.sol";
import "./RSOperator.sol";
import "./RSContributor.sol";


pragma solidity ^0.4.11; //We have to specify what version of the compiler this code will use

contract RSNetwork is Administered {

  using ConvertLib for *;
  
  struct resourceNet {
      string rsName;
      bytes32 rsType;
      address rsAddress; // The address of the question
      uint rsIdx;
      bool isActive;
      
  }
  
  bytes32[] rsTypes;
  mapping (bytes32 => resourceNet[]) private rsInfo;  
  mapping (address => mapping(bytes32 => resourceNet)) private rsNetInfo;  
     
  GoodwillCoin rsToken;
  RSOperator rsOperator;
  RSContributor rsContributor;
  
  function RSNetwork(GoodwillCoin _rsToken, RSOperator _rsOperator, RSContributor _rsContributor, address[] adminAddress) 
      Administered(adminAddress)
  {
  
      rsToken=_rsToken;
      rsOperator=_rsOperator;
      rsContributor=_rsContributor;
    
  }

  function SetResourceTerm(bytes32 _rsName, bytes32 rsType, uint _rsToken) {
  
  }
  
  function ListResourceNet(bytes32 _rsType) returns (uint, uint[], uint[], bytes) {
        uint transactions=0;
        resourceNet[] memory signatures;
        
        transactions = rsInfo[_rsType].length;
        signatures = rsInfo[_rsType];

        uint[] memory addresses=new uint[](transactions);
        uint[] memory rsidx=new uint[](transactions);
        string memory b3;
       
        uint idx=0;
        for (uint i=0; i < transactions; i++) {
          if (signatures[i].isActive) {
              addresses[idx]=uint(signatures[i].rsAddress);
              rsidx[idx]=signatures[i].rsIdx;
              b3 = b3.toSlice().concat(signatures[i].rsName.toSlice());
              b3 = b3.toSlice().concat('~~~'.toSlice());
              idx+=1;
          }          
        }
        
        return (idx, addresses, rsidx, bytes(b3));
  }


  function ListResourceType() returns (bytes32[]) {
      return rsTypes;
  }
  

  function DelistResourceNet(bytes32 _rsType, uint _rsIdx) returns (bool) {
      if (rsInfo[_rsType][_rsIdx].rsAddress == msg.sender) {
          rsInfo[_rsType][_rsIdx].isActive=false;
     }
     return true;
  }


  function CreateResourceNet(string _rsName, address _rsAddress, bytes32 _rsType) returns (bool)
  {
      if (rsNetInfo[_rsAddress][_rsType].rsAddress == 0) {
          resourceNet memory v=resourceNet(_rsName, _rsType, _rsAddress, 0, true);
          v.isActive=true;
          rsInfo[_rsType].push(v);
    
          uint rsIdx=rsInfo[_rsType].length - 1;
          rsInfo[_rsType][rsIdx].rsIdx=rsIdx;
          
          rsNetInfo[_rsAddress][_rsType]=v;
          
          return true;
      }
      return false;
  }
  

}