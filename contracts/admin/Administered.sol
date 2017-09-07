pragma solidity ^0.4.11;


/**
 * @title Admin
 * @dev The Admin contract has Admin addresses, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Administered {
  mapping (address => bool) isAdmin;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Administered(address[] adminAddress) {
    for (uint i=0; i < adminAddress.length; i++) {
        isAdmin[adminAddress[i]]=true;
    } 
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyAdmin() {
    require(isAdmin[msg.sender]);
    _;
  }
  
  function addAdmin(address admin) {
        assert(isAdmin[msg.sender]);
        isAdmin[admin]=true;
  }
    

}
