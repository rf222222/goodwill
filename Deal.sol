import "./admin/Administered.sol";
import "./ConvertLib.sol";
import "./GoodwillCoin.sol";

pragma solidity ^0.4.11; //We have to specify what version of the compiler this code will use

contract Deal is Administered {
  using ConvertLib for *;
  
  GoodwillCoin gc;
  struct deal {
  
    address dealAddress;
    bytes32 dealInst;
    bytes32 dealInstName;
    uint dealInstId;
    
    uint transactions;

  }
  mapping (bytes32 => uint) fees;
  mapping (bytes32 => deal) private dealInfo;
  
  function Deal(GoodwillCoin _gc, address[] adminAddress) 
      Administered(adminAddress)
  {
    gc=_gc;
    
  }
  
  function transferFrom(bytes32 inst, bytes32 regType, uint value) returns (bool) {
      address voterAddress = msg.sender;
      return adminTransferFrom(voterAddress, inst, regType, value);
      
  }
  
  function reserveFrom(bytes32 inst, bytes32 regType, uint value) returns (bool) {
      address voterAddress = msg.sender;
      return adminReserveFrom(voterAddress, inst, regType, value);
      
  }
  
  function releaseReserveFrom(bytes32 inst, bytes32 regType, uint value) returns (bool) {
      address voterAddress = msg.sender;
      return adminReleaseReserveFrom(voterAddress, inst, regType, value);
      
  }
  
  
  function fundDeal(bytes32 dealInst, uint votesInTokens)  {
        
        gc.transferFrom(msg.sender, dealInfo[dealInst].dealAddress, votesInTokens);

  }
  
  
  function isHost(bytes32 inst, address user) returns (bool) {
      if (dealInfo[inst].dealAddress == user) {
          return true;
      } else {
          return false;
      }
  }
  
  
  function hasDeal(bytes32 inst) returns (bool) {
      if (dealInfo[inst].dealAddress > 0) {
          return true;
      } else {
          return false;
      }
  }
  
  function dealDetails(bytes32 dealInst) constant returns (uint, uint, uint) {
    
    return gc.userDetails(dealInfo[dealInst].dealAddress);
    
  }

  function adminTransferFrom(address voterAddress, bytes32 inst, bytes32 regType, uint value) onlyAdmin returns (bool) {
      
      if (gc.adminTransferFrom(voterAddress, dealInfo[inst].dealAddress, value)) {
          if (fees[regType] > 0) {
              gc.adminTransferFrom(voterAddress, admins[0], fees[regType]);
          }
          return true;
      } else {
          return false;
      }
      
  }
  
  function adminReserveFrom(address voterAddress, bytes32 inst, bytes32 regType, uint value) onlyAdmin returns (bool) {
      
      if (voterAddress == dealInfo[inst].dealAddress)
          return false;
          
      if (gc.adminReserveFrom(voterAddress, dealInfo[inst].dealAddress, value)) {
          if (fees[regType] > 0) {
              gc.adminTransferFrom(voterAddress, admins[0], fees[regType]);
          }
          return true;
      } else {
          return false;
      }
      
  }
  
  function adminReleaseReserveFrom(address voterAddress, bytes32 inst, bytes32 regType, uint value) onlyAdmin returns (bool) {
      
      if (voterAddress == dealInfo[inst].dealAddress)
          return false;
          
      if (gc.adminReleaseReserveFrom(voterAddress, dealInfo[inst].dealAddress, value)) {
          if (fees[regType] > 0) {
              gc.adminTransferFrom(voterAddress, admins[0], fees[regType]);
          }
          return true;
      } else {
          return false;
      }
      
  }
  
  function adminReverseReserveFrom(address voterAddress, bytes32 inst, bytes32 regType, uint value)  onlyAdmin  returns (bool) {
      
      if (voterAddress == dealInfo[inst].dealAddress)
          return false;
          
      if (gc.adminReverseReserveFrom(voterAddress, dealInfo[inst].dealAddress, value)) {
          if (fees[regType] > 0) {
              gc.adminTransferFrom(voterAddress, admins[0], fees[regType]);
          }
          return true;
      } else {
          return false;
      }
      
  }
  
  function dealAuth(address voterAddress, uint cost, bytes32 dealInst, bytes32 dealInstName, uint dealInstId) onlyAdmin returns (bool) {
  
      if (cost > 0) {
          gc.transferFrom(voterAddress, msg.sender, cost);
      }
            
      dealInfo[dealInst].dealAddress=voterAddress;
      dealInfo[dealInst].dealInst=dealInst;
      dealInfo[dealInst].dealInstName=dealInstName;
      dealInfo[dealInst].dealInstId=dealInstId;
      
      return true;
      
  }
  
  
  function feeAuth(bytes32 regType, uint cost) onlyAdmin returns (bool) {
  
      fees[regType]=cost;
            
      return true;
      
  }
}