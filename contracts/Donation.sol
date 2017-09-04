import "./ConvertLib.sol";
import "./Deal.sol";

pragma solidity ^0.4.11; //We have to specify what version of the compiler this code will use

contract Donation {
  using ConvertLib for *;
  
  // We use the struct datatype to store the voter information.
  struct signature {
      address signatureAddress;
      uint date;
      uint tokensSpent;
      bytes32 regType;
      string desc;
      
  }
  
  struct donation {
  
    signature[] donationSignHistory;
    bytes32 inst;
    uint tokenReceived;
     
  }

  mapping (bytes32 => mapping(address => signature[])) private donationSignInfo;
  mapping (address => signature[]) private signatureInfo;
  mapping (bytes32 => donation) private donationInfo;
  mapping (address => bool) private isAdmin;
   
  Deal deal;
  
  function Donation(Deal _deal, address[] adminAddress) {
    deal=_deal;
    
    for (uint i=0; i < adminAddress.length; i++) {
        isAdmin[adminAddress[i]]=true;
    }
    
  }
  
  function addAdmin(address admin) {
        assert(isAdmin[msg.sender]);
        isAdmin[admin]=true;
  }

  function signAdmin(address voterAddress, bytes32 inst, uint cost , bytes32 regType, string desc) returns (bool) {
      assert(isAdmin[msg.sender]);
      
      if (deal.adminTransferFrom(voterAddress, inst, regType, cost)) {
          signature memory v=signature(voterAddress, now, cost, regType, desc);
          donationInfo[inst].donationSignHistory.push(v);

          donationInfo[inst].tokenReceived=ConvertLib.safeAdd(donationInfo[inst].tokenReceived,cost);
          
          donationSignInfo[inst][voterAddress].push(v);
          signatureInfo[voterAddress].push(v);
          return true;
      }
      return false;
  }
  
  function sign(bytes32 inst, uint cost, bytes32 regType, string desc) returns (bool) {
      address voterAddress = msg.sender;
      return signAdmin(voterAddress, inst, cost , regType, desc);
  }
  
  
  function donationSignHistory(bytes32 inst) constant returns (uint, uint[], uint[], bytes32[], bytes) {
    uint transactions=0;
    signature[] memory signatures;
    
    if (deal.isHost(inst, msg.sender)) {
          transactions = donationInfo[inst].donationSignHistory.length;
          signatures=donationInfo[inst].donationSignHistory;
          
    } else {
          transactions = donationSignInfo[inst][msg.sender].length;
          signatures=donationSignInfo[inst][msg.sender];
    
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
    
    return (donationInfo[inst].donationSignHistory.length,  donationSignInfo[inst][voterAddress].length, signatureInfo[voterAddress].length);
    
  }
  

}