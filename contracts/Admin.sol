import "./ConvertLib.sol";
import "./GoodwillCoin.sol";
import "./User.sol";

pragma solidity ^0.4.11; //We have to specify what version of the compiler this code will use

contract Admin is User {
  using ConvertLib for *;
  GoodwillCoin gc;
  
  fund_request[] private fundRequestHistory; 
  fund_request[] private fundApproveHistory;
  fund_request[] private fundRejectHistory;
    
  mapping (address => bool) private isAdmin;
  
  struct fund_request {
    address voterAddress;
    uint tokenRequest;
    uint requestDate;
    bool is_approved;
    address approverAddress;
    uint approveDate;
    
  }
  
 
  function Admin(GoodwillCoin _gc, address[] adminAddress) {
    gc=_gc;
    for (uint i=0; i < adminAddress.length; i++) {
        isAdmin[adminAddress[i]]=true;
    } 
    admins=adminAddress; 
  }

  function addAdmin(address admin) {
        assert(isAdmin[msg.sender]);
        isAdmin[admin]=true;
  }
  
  function requestFunding(uint votesInTokens, uint voterId, string voterName) returns (uint) {
     address user=msg.sender;
     voterInfo[user].voterId=voterId;
     voterInfo[user].voterName=voterName;
     
     fundRequestHistory.push(fund_request(user, votesInTokens, now, false, 0, 0));
        
     return (votesInTokens);
    
  }

  function approveFunding( uint fidx, bool decision, uint voterId, string voterName) returns (uint) {
    address user=msg.sender;
    
    assert(isAdmin[user]);
    assert(fundRequestHistory.length > fidx);
    assert(fundRequestHistory[fidx].approveDate == 0);
    
    adminInfo[user].voterId=voterId;
    adminInfo[user].voterName=voterName;
    
    uint tokenGiven=0;
    fundRequestHistory[fidx].is_approved=decision;
    fundRequestHistory[fidx].approverAddress=user;
    fundRequestHistory[fidx].approveDate=now;
    
    if (decision) {
        fundApproveHistory.push(fundRequestHistory[fidx]);
        uint votesInTokens=fundRequestHistory[fidx].tokenRequest;
        address voter=fundRequestHistory[fidx].voterAddress;
        
        gc.mint(voter, votesInTokens);
            
        //gc.adminTransfer(voter, votesInTokens, voterId, voterName);
        tokenGiven=votesInTokens;
    } else {
        fundRejectHistory.push(fundRequestHistory[fidx]);
    }
        
    return (tokenGiven);
    
  }
  
    
  function fundingReqHistory() returns (uint[], uint[], uint[], bool[], uint[], uint[], bytes) {
    uint transactions=fundRequestHistory.length;
    
    uint[] memory req_ids=new uint[](transactions);
    uint[] memory req_amounts=new uint[](transactions);
    uint[] memory req_dates=new uint[](transactions);
    bool[] memory req_approved=new bool[](transactions);
    uint[] memory approve_ids=new uint[](transactions);
    uint[] memory approve_dates=new uint[](transactions);
    string memory b3;
    
    
    for(uint i = 0; i < fundRequestHistory.length; i++) {
    
      b3=b3.toSlice().concat(voterInfo[fundRequestHistory[i].voterAddress].voterName.toSlice());
      b3=b3.toSlice().concat('|||'.toSlice());
      b3=b3.toSlice().concat(adminInfo[fundRequestHistory[i].approverAddress].voterName.toSlice());
      req_ids[i]=voterInfo[fundRequestHistory[i].voterAddress].voterId;
      req_amounts[i]=fundRequestHistory[i].tokenRequest;
      req_dates[i]=fundRequestHistory[i].requestDate;
      req_approved[i]=fundRequestHistory[i].is_approved;
      approve_ids[i]=adminInfo[fundRequestHistory[i].approverAddress].voterId;  
      approve_dates[i]=fundRequestHistory[i].approveDate;
      b3=b3.toSlice().concat('~~~'.toSlice());
      
    }

    return (req_ids, req_amounts, req_dates, req_approved, approve_ids, approve_dates, bytes(b3));
  }
  
 
}