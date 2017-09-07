import "./admin/Administered.sol";
import "./ConvertLib.sol";
import "./Deal.sol";

pragma solidity ^0.4.11; //We have to specify what version of the compiler this code will use

contract Escrow is Administered {
  using ConvertLib for *;
  
  enum Stages {
        ReserveSent,
        ReserveRejected,
        ReserveAccepted,
        PromiseActioned,
        ActionRejected,
        ActionVerified,
        PaymentVerified,
        Complete
  }
    
  // We use the struct datatype to store the voter information.
  struct signature {
      address signatureAddress;
      uint signatureDate;
      uint tokenReserve;
      Stages actionStage;      
      bytes32 regType;
      string actionDetails;
      uint actionDate;
      uint stageIdx;
  }
  
  struct escrow {
  
    signature[] escrowSignHistory;
    bytes32 inst;
    uint tokenReceived;
     
  }
  
  mapping (bytes32 => mapping(address => mapping(uint => signature[]))) private escrowSignStageInfo;
  mapping (bytes32 => mapping(address => signature[])) private escrowSignInfo;
  mapping (address => signature[]) private signatureInfo;
  mapping (bytes32 => escrow) private escrowInfo;

  Deal deal;
  
  function Escrow(Deal _deal, address[] adminAddress) 
      Administered(adminAddress)
  {

    deal=_deal;
    
  }
  
  function signAdmin(address voterAddress, bytes32 inst, uint cost , bytes32 regType, string desc) onlyAdmin returns (bool, uint) {
      //assert(isAdmin[msg.sender]);
      
      if (deal.adminReserveFrom(voterAddress, inst, regType, cost)) {
      
          signature memory v=signature(voterAddress, now, cost, Stages.ReserveSent, regType, desc, now, escrowInfo[inst].escrowSignHistory.length);
          escrowInfo[inst].escrowSignHistory.push(v);              
          escrowSignInfo[inst][voterAddress].push(v);        
          escrowSignStageInfo[inst][voterAddress][v.stageIdx].push(v);          
          signatureInfo[voterAddress].push(v);
          
          return (true, v.stageIdx);
      }
      return (false, 0);
      
  }
  
  function sign(bytes32 inst, uint cost , bytes32 regType, string desc) returns (bool, uint) {
      return signAdmin(msg.sender, inst, cost , regType, desc);            
  }
  
  function answer(bytes32 inst, uint idx , bool answer, bytes32 regType, string desc) returns (bool) {
      return answerAdmin(msg.sender, inst, idx, answer, regType, desc);  
  }
  
  function answerAdmin(address voterAddress, bytes32 inst, uint idx , bool answer, bytes32 regType, string desc) onlyAdmin returns (bool) {
      //assert(isAdmin[msg.sender]);
      
      signature memory sign=escrowInfo[inst].escrowSignHistory[idx];
      if (deal.isHost(inst, voterAddress)) {
              if (sign.actionStage == Stages.ReserveSent) {
                  if (answer) {
                      sign.actionStage=Stages.ReserveAccepted;
                  } else {
                      sign.actionStage=Stages.ReserveRejected;
                      if (!deal.adminReverseReserveFrom(sign.signatureAddress, inst, regType, sign.tokenReserve)) {
                          return false;
                      }
                  }
              } else if (sign.actionStage == Stages.ReserveAccepted) {
                  if (answer) {
                      sign.actionStage=Stages.PromiseActioned;
                  } 
              } else if (sign.actionStage == Stages.ActionRejected) {
                  if (answer) {
                      sign.actionStage=Stages.PromiseActioned;
                  } else {
                      sign.actionStage=Stages.ReserveRejected;
                      if (!deal.adminReverseReserveFrom(sign.signatureAddress, inst, regType, sign.tokenReserve)) {
                          return false;
                      }
                  }
              } else if (sign.actionStage == Stages.ActionVerified) {
                  if (answer) {
                      sign.actionStage=Stages.PaymentVerified;
                  } 
              }
                      
      } else {
          if (sign.actionStage == Stages.ReserveSent) {
                  if (answer) {
                      sign.actionStage=Stages.ReserveRejected;
                      if (!deal.adminReverseReserveFrom(sign.signatureAddress, inst, regType, sign.tokenReserve)) {
                          return false;
                      }
                  } 
          } else if (sign.actionStage == Stages.PromiseActioned) {
                  if (answer) {
                      sign.actionStage=Stages.ActionVerified;
                      if (!deal.adminReleaseReserveFrom(sign.signatureAddress, inst, regType, sign.tokenReserve)) {
                          return false;
                      }
                  } else {
                      sign.actionStage=Stages.ActionRejected;
                  }
          } else if (sign.actionStage == Stages.PaymentVerified) {
                  if (answer) {
                      sign.actionStage=Stages.Complete;
                  }
          }
     }
               
     sign.actionDetails = sign.actionDetails.toSlice().concat('```'.toSlice());
     sign.actionDetails = sign.actionDetails.toSlice().concat(desc.toSlice());                
     escrowInfo[inst].escrowSignHistory[idx]=sign;
     
     signatureInfo[voterAddress].push(sign);

     sign.actionDetails = desc;                              
     escrowSignStageInfo[inst][sign.signatureAddress][idx].push(sign);
      
     return true;
            
  }
  
  function escrowSignStageHistory(bytes32 inst, uint idx) constant returns (uint, uint[], uint[], bytes) {
  
    signature[] memory signatures;
    
    if (deal.isHost(inst, msg.sender)) {
          signatures=escrowSignStageInfo[inst][escrowInfo[inst].escrowSignHistory[idx].signatureAddress][idx];
          
    } else {
          signatures=escrowSignStageInfo[inst][msg.sender][idx];    
          
    }
    
    uint[] memory timestamp=new uint[](signatures.length);
    uint[] memory stage=new uint[](signatures.length);
    string memory b3;
   
    for (uint i=0; i < signatures.length; i++) {
              
      timestamp[i]=signatures[i].signatureDate;
      stage[i]=uint(signatures[i].actionStage);
      b3 = b3.toSlice().concat(signatures[i].actionDetails.toSlice());
      b3 = b3.toSlice().concat('~~~'.toSlice());
      
    }
    return (signatures.length, timestamp, stage, bytes(b3));
    
  }
    
    
  function escrowSignHistory(bytes32 inst) constant returns (uint, uint[], uint[], uint[], bytes) {
  
    uint transactions=0;
    signature[] memory signatures;
    
    if (deal.isHost(inst, msg.sender)) {
          transactions = escrowInfo[inst].escrowSignHistory.length;
          signatures=escrowInfo[inst].escrowSignHistory;
          
    } else {
          transactions = escrowSignInfo[inst][msg.sender].length;
          signatures=escrowSignInfo[inst][msg.sender];
    
    }
    uint[] memory timestamp=new uint[](transactions);
    uint[] memory cost=new uint[](transactions);
    uint[] memory idx=new uint[](transactions);
    string memory b3;
   
    for (uint i=0; i < transactions; i++) {
              
      timestamp[i]=signatures[i].signatureDate;
      cost[i]=signatures[i].tokenReserve;
      idx[i]=signatures[i].stageIdx;
      b3 = b3.toSlice().concat(signatures[i].actionDetails.toSlice());
      b3 = b3.toSlice().concat('~~~'.toSlice());
      
    }
    return (transactions, timestamp, cost, idx, bytes(b3));
    
  }
    
  function escrowHistory() constant returns (uint, uint[], uint[], uint[], bytes) {
  
    uint transactions=0;
    signature[] memory signatures;
    
    transactions = signatureInfo[msg.sender].length;
    signatures=signatureInfo[msg.sender];
    
    uint[] memory timestamp=new uint[](transactions);
    uint[] memory cost=new uint[](transactions);
    uint[] memory idx=new uint[](transactions);
    string memory b3;
   
    for (uint i=0; i < transactions; i++) {
              
      timestamp[i]=signatures[i].signatureDate;
      cost[i]=signatures[i].tokenReserve;
      idx[i]=signatures[i].stageIdx;
      b3 = b3.toSlice().concat(signatures[i].actionDetails.toSlice());
      b3 = b3.toSlice().concat('~~~'.toSlice());
      
    }
    return (transactions, timestamp, cost, idx, bytes(b3));
    
  }
    
  
  function historyTotal(bytes32 inst, address voterAddress) constant returns (uint, uint, uint) { 
    
    return (escrowInfo[inst].escrowSignHistory.length,  escrowSignInfo[inst][voterAddress].length, signatureInfo[voterAddress].length);
    
  }

  
  

}