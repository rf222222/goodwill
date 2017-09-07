import "./admin/Administered.sol";
import "./ConvertLib.sol";
import "./GoodwillCoin.sol";

pragma solidity ^0.4.11; //We have to specify what version of the compiler this code will use

contract QA is Administered {
  using ConvertLib for *;
  
  struct qa {
      address q_userAddress; // The address of the question
      uint questionDate;
      string qa_question;
      
      address a_userAddress; // The address of the answer
      uint answerDate;
      string qa_answer;
  }

  GoodwillCoin gc;
    
  mapping (bytes32 => qa[]) private qaInfo;
  
  function QA(GoodwillCoin _gc, address[] adminAddress) 
      Administered(adminAddress)
  {

    gc=_gc;

  }

  function qForCandidate(bytes32 dealInst, uint votesInTokens, string q_question) returns (uint) {    
  
    address user=msg.sender;   
    qaInfo[dealInst].push(qa(user, now, q_question, 0,  0, ''));
    
    gc.spend(msg.sender, votesInTokens);
    
    return votesInTokens;
    
  }

  function aFromCandidate(bytes32 dealInst, uint votesInTokens, uint qidx, string a_answer) returns (uint) {

    address user=msg.sender;
    
    qaInfo[dealInst][qidx].qa_answer=a_answer;
    qaInfo[dealInst][qidx].answerDate=now;
    qaInfo[dealInst][qidx].a_userAddress=user;
     
    gc.spend(msg.sender, votesInTokens);
    
    return votesInTokens;
    
  }
  
  function qaQHistory(bytes32 dealInst) constant returns (uint, address[], uint[], bytes) {
          
    uint transactions=qaInfo[dealInst].length;
    
    address[] memory q_userAddress=new address[](transactions);
    uint[] memory questionDate=new uint[](transactions);
    uint[] memory ids=new uint[](transactions);
    string memory b3;
    
    for(uint i = 0; i < qaInfo[dealInst].length; i++) {
            
      q_userAddress[i]=qaInfo[dealInst][i].q_userAddress;
      questionDate[i]=qaInfo[dealInst][i].questionDate;
      b3 = b3.toSlice().concat(qaInfo[dealInst][i].qa_question.toSlice());
      b3 = b3.toSlice().concat('~~~'.toSlice());
    
    }

    return (transactions, q_userAddress, questionDate, bytes(b3));
    
  }

  function qaAHistory(bytes32 dealInst) constant returns (uint, address[], uint[], bytes) {
          
    uint transactions=qaInfo[dealInst].length;

    address[] memory a_userAddress=new address[](transactions);
    uint[] memory answerDate=new uint[](transactions);

    uint[] memory ids=new uint[](transactions);
    string memory b3;

    for(uint i = 0; i < qaInfo[dealInst].length; i++) {

      a_userAddress[i]=qaInfo[dealInst][i].a_userAddress;
      answerDate[i]=qaInfo[dealInst][i].answerDate;
      b3 = b3.toSlice().concat(qaInfo[dealInst][i].qa_answer.toSlice());
      b3 = b3.toSlice().concat('~~~'.toSlice());

    }
    
    return (transactions, a_userAddress, answerDate, bytes(b3));
    
  }
    

}