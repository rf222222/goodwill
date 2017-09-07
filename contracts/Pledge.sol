import "./admin/Administered.sol";
import "./ConvertLib.sol";
import "./Deal.sol";

pragma solidity ^0.4.11; //We have to specify what version of the compiler this code will use

contract Pledge is Administered {
  using ConvertLib for *;
  
  // We use the struct datatype to store the voter information.
  struct signature {
      address signatureAddress;
      uint date;
      uint tokensSpent;
      bytes32 regType;
      string desc;
      
  }
  
  struct pledge {
  
    signature[] pledgeSignHistory;
    bytes32 inst;
    uint tokenReceived;
     
  }

  mapping (bytes32 => mapping(address => signature[])) private pledgeSignInfo;
  mapping (address => signature[]) private signatureInfo;
  mapping (bytes32 => pledge) private pledgeInfo;
   
  Deal deal;
  
  function Pledge(Deal _deal, address[] adminAddress) 
      Administered(adminAddress)
  {
  
    deal=_deal;
    
  }

  function signAdmin(address voterAddress, bytes32 inst, uint cost , bytes32 regType, string desc) onlyAdmin returns (bool) {
      assert(isAdmin[msg.sender]);
      
      if (deal.adminTransferFrom(voterAddress, inst, regType, cost)) {
          signature memory v=signature(voterAddress, now, cost, regType, desc);
          pledgeInfo[inst].pledgeSignHistory.push(v);

          pledgeInfo[inst].tokenReceived=ConvertLib.safeAdd(pledgeInfo[inst].tokenReceived,cost);
          
          pledgeSignInfo[inst][voterAddress].push(v);
          signatureInfo[voterAddress].push(v);
          return true;
      }
      return false;
  }
  
  function sign(bytes32 inst, uint cost, bytes32 regType, string desc) returns (bool) {
      address voterAddress = msg.sender;
      return signAdmin(voterAddress, inst, cost , regType, desc);
  }
  
  function pledgeSignHistory(bytes32 inst) constant returns (uint, uint[], uint[], bytes32[], bytes) {
    uint transactions=0;
    signature[] memory signatures;
    
    if (deal.isHost(inst, msg.sender)) {
          transactions = pledgeInfo[inst].pledgeSignHistory.length;
          signatures=pledgeInfo[inst].pledgeSignHistory;
          
    } else {
          transactions = pledgeSignInfo[inst][msg.sender].length;
          signatures=pledgeSignInfo[inst][msg.sender];
    
    }
    uint[] memory timestamp=new uint[](transactions);
    uint[] memory cost=new uint[](transactions);
    bytes32[] memory regType=new bytes32[](transactions);
    string memory b3;
   
    for (uint i=0; i < transactions; i++) {
              
      timestamp[i]=signatures[i].date;
      cost[i]=signatures[i].tokensSpent;
      regType[i]=signatures[i].regType;
      b3 = b3.toSlice().concat(signatures[i].desc.toSlice());
      b3 = b3.toSlice().concat('~~~'.toSlice());
      
    }
    return (transactions, timestamp, cost, regType, bytes(b3));
  }
  
  function historyTotal(bytes32 inst, address voterAddress) constant returns (uint, uint, uint) { 
    
    return (pledgeInfo[inst].pledgeSignHistory.length,  pledgeSignInfo[inst][voterAddress].length, signatureInfo[voterAddress].length);
    
  }
  

}