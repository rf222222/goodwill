import "./ConvertLib.sol";

pragma solidity ^0.4.11; //We have to specify what version of the compiler this code will use

contract User {

  using ConvertLib for *;
  
  function User() {
  }

  struct voter {
    string voterName;
    uint voterId;
  }
 
  mapping (address => voter) internal voterInfo;
  mapping (address => voter) internal adminInfo;

}