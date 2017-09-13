pragma solidity ^0.4.11;


/**
 * @title Admin
 * @dev The Admin contract has Admin addresses, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Administered {
  mapping (address => bool) isAdmin;
  mapping (address => bool) isBanned;
  address[] admins;

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Administered(address[] adminAddress) {
    for (uint i=0; i < adminAddress.length; i++) {
        isAdmin[adminAddress[i]]=true;
    } 
    admins=adminAddress;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyAdmin() {
    require(isAdmin[msg.sender]);
    require(!isBanned[msg.sender]);
    _;
  }
  
  function addAdmin(address admin) onlyAdmin {
        require(isAdmin[msg.sender]);
        require(!isBanned[msg.sender]);
        isAdmin[admin]=true;
        admins.push(admin);
  }
  
  function addBanned(address banned) onlyAdmin {
        require(isAdmin[msg.sender]);
        require(!isBanned[msg.sender]);
        isBanned[banned]=true;
  }

  function getAdmins() constant returns (address[]) {
        require(isAdmin[msg.sender]);
        require(!isBanned[msg.sender]);
        return admins;
  }


}
