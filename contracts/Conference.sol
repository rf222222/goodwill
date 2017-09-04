import "./ConvertLib.sol";
import "./GoodwillCoin.sol";

pragma solidity ^0.4.11; //We have to specify what version of the compiler this code will use

contract Conference {
  using ConvertLib for *;
  
  // We use the struct datatype to store the voter information.
  struct applicant {
      address applicantAddress;
      uint date;
      uint tokensSpent;
      bytes32 regType;
      string desc;
      
  }
  
  struct conference {
    address confAddress;
    applicant[] registerHistory;
    bytes32 inst;
    bytes32 instName;
    uint instId;
    uint tokenReceived;
    uint tokenBalance;
    mapping(bytes32 => uint) fees;
     
  }

  mapping (bytes32 => mapping(address => applicant[])) private registerInfo;
  mapping (address => applicant[]) private applicantInfo;
  mapping (bytes32 => conference) private conferenceInfo;
  mapping (address => bool) private isAdmin;
   
  GoodwillCoin gc;
  
  function Conference(GoodwillCoin _gc, address[] adminAddress) {
    gc=_gc;
    
    for (uint i=0; i < adminAddress.length; i++) {
        isAdmin[adminAddress[i]]=true;
    }
    
  }

  function addAdmin(address admin) {
        assert(isAdmin[msg.sender]);
        isAdmin[admin]=true;
  }
  
  function attendAdmin(address voterAddress, bytes32 inst, uint cost , bytes32 regType, string desc) returns (bool) {
      assert(isAdmin[msg.sender]);
      conferenceInfo[inst].fees[regType]=cost;
      
      for (uint i=0; i < registerInfo[inst][voterAddress].length; i++) {
          if (registerInfo[inst][voterAddress][i].date > 0 && registerInfo[inst][voterAddress][i].regType == regType)
              return true;
      }
      
      if (gc.adminTransferFrom(voterAddress, conferenceInfo[inst].confAddress, cost)) {
          applicant memory v=applicant(voterAddress, now, cost, regType, desc);
          conferenceInfo[inst].registerHistory.push(v);
          conferenceInfo[inst].tokenReceived+=cost;
          conferenceInfo[inst].tokenBalance+=cost;
          
          registerInfo[inst][voterAddress].push(v);
          applicantInfo[voterAddress].push(v);
          return true;
      }
      return false;
  }
  
  function attend(bytes32 inst, bytes32 regType, string desc) returns (bool) {
      address voterAddress = msg.sender;
      
      uint cost=conferenceInfo[inst].fees[regType];
      return attendAdmin(voterAddress, inst, cost, regType, desc); 
      
  }
  
  function registerHistory(bytes32 inst) constant returns (uint, uint[], uint[], bytes32[], bytes) {
    uint transactions=0;
    applicant[] memory applicants;
    
    if (conferenceInfo[inst].confAddress == msg.sender) {
          transactions = conferenceInfo[inst].registerHistory.length;
          applicants=conferenceInfo[inst].registerHistory;
    } else {
          transactions = registerInfo[inst][msg.sender].length;
          applicants=registerInfo[inst][msg.sender];
    
    }
    uint[] memory timestamp=new uint[](transactions);
    uint[] memory cost=new uint[](transactions);
    bytes32[] memory regType=new bytes32[](transactions);
    string memory b3;
   
    for (uint i=0; i < transactions; i++) {
              
      timestamp[i]=applicants[i].date;
      cost[i]=applicants[i].tokensSpent;
      regType[i]=applicants[i].regType;
      b3 = b3.toSlice().concat(applicants[i].desc.toSlice());
      b3 = b3.toSlice().concat('~~~'.toSlice());
    }
    return (transactions, timestamp, cost, regType, bytes(b3));
    
  }
  
  function historyTotal(bytes32 inst, address voterAddress) constant returns (uint, uint, uint) { 
    
    return (conferenceInfo[inst].registerHistory.length,  registerInfo[inst][voterAddress].length, applicantInfo[voterAddress].length);
  }

  
  function conferenceAuth(address voterAddress, bytes32 inst, bytes32 instName, uint instId) returns (bool) {
  
      assert(isAdmin[msg.sender]);
      
      conferenceInfo[inst].confAddress=voterAddress;
      conferenceInfo[inst].inst=inst;
      conferenceInfo[inst].instName=instName;
      conferenceInfo[inst].instId=instId;
            
      return true;
      
  }
  
  function feeAuth(address voterAddress, bytes32 inst, bytes32 regType, uint cost) returns (bool) {
  
      assert(isAdmin[msg.sender]);
      
      conferenceInfo[inst].confAddress=voterAddress;
      conferenceInfo[inst].inst=inst;
      conferenceInfo[inst].fees[regType]=cost;
            
      return true;
      
  }
  
}