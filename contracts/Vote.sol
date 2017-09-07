import "./admin/Administered.sol";
import "./ConvertLib.sol";
import "./GoodwillCoin.sol";

pragma solidity ^0.4.11; //We have to specify what version of the compiler this code will use

contract Vote is Administered { 
  using ConvertLib for *;
  // We use the struct datatype to store the voter information.
  
  struct vote_tally {
      address voterAddress;
      uint voteDate;
      uint voteCount;
      bytes32 dealInst;
      string voteDesc;
  }
  
  
  struct voter {
      vote_tally[] voteTally;
      mapping (bytes32 => uint) voteCount; // Mapping to keep track of votes per dealInst.
  }
  
  mapping (bytes32 => mapping (address => voter)) private eventVoteHistory;
  
  mapping (bytes32 => mapping (bytes32 => uint)) private eventVoteTally;
  
  mapping (bytes32 => vote_tally[]) private eventHistory;
  
  GoodwillCoin gc;
  
  function Vote(GoodwillCoin _gc, address[] adminAddress) 
      Administered(adminAddress)
  {
 
    gc=_gc;
    
  }


  function voteForCandidate(bytes32 eventInst, bytes32 dealInst, uint votesInTokens, string desc) returns (uint) {
    address user = msg.sender;
    if (eventVoteHistory[eventInst][msg.sender].voteCount[dealInst] >= 1 && isAdmin[user]==false) throw;

    vote_tally memory v=vote_tally(msg.sender, now, votesInTokens, dealInst, desc);
    eventVoteTally[eventInst][dealInst]+=1;
    eventHistory[eventInst].push(v);
    eventVoteHistory[eventInst][msg.sender].voteTally.push(v);
    eventVoteHistory[eventInst][msg.sender].voteCount[dealInst]+=1;
    gc.spend(msg.sender, votesInTokens);
        
    return (eventVoteTally[eventInst][dealInst]);
    
  }

  function voteHistory(bytes32 eventInst) constant returns (uint, uint[], uint[], bytes32[], bytes) {
  
    uint[] memory timestamp=new uint[](eventHistory[eventInst].length);
    uint[] memory votes=new uint[](eventHistory[eventInst].length);
    bytes32[] memory names=new bytes32[](eventHistory[eventInst].length);
    string memory b3;
      
    for(uint i = 0; i <  eventHistory[eventInst].length; i++) {
    
      timestamp[i]=eventHistory[eventInst][i].voteDate;
      votes[i]=eventHistory[eventInst][i].voteCount;
      names[i]=eventHistory[eventInst][i].dealInst;
      b3 = b3.toSlice().concat(eventHistory[eventInst][i].voteDesc.toSlice());
      b3 = b3.toSlice().concat('~~~'.toSlice());
      
    }
    return (eventHistory[eventInst].length, timestamp, votes, names, bytes(b3));
    
  }
  

}