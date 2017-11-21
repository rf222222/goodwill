import "./admin/Administered.sol";
import "./ConvertLib.sol";
//import "./GoodwillCoin.sol";
import "./RSLogistics.sol";


pragma solidity ^0.4.11; //We have to specify what version of the compiler this code will use

contract RSContributor is Administered {

  using ConvertLib for *;

  //GoodwillCoin rsToken;
  RSLogistics rsLogistics;

  struct resource {
      address rsAddress; // The address of the question
      bytes32 rsType;
      uint rsQty;
      string rsDesc;
      uint rsDate;
      uint rsIdx;
  }

  mapping (address => mapping (bytes32 => resource[])) private rsContributionInfo;
  mapping (address => bytes32[]) private rsContributionTypes;

  function RSContributor(RSLogistics _rsLogistics, address[] adminAddress)
      Administered(adminAddress)
  {

      //rsToken=_rsToken;
      rsLogistics=_rsLogistics;

  }

  function ListResource(address _rsAddress, bytes32 _rsType) returns (uint, uint[], uint[], uint[], bytes) {

        resource[] memory signatures;
        uint transactions=0;

        transactions = rsContributionInfo[_rsAddress][_rsType].length;
        signatures = rsContributionInfo[_rsAddress][_rsType];

        uint[] memory rsDates=new uint[](transactions);
        uint[] memory rsIdx=new uint[](transactions);
        uint[] memory rsQty=new uint[](transactions);
        string memory b3;

        for (uint i=0; i < transactions; i++) {

          rsDates[i]=signatures[i].rsDate;
          rsIdx[i]=signatures[i].rsIdx;
          rsQty[i]=signatures[i].rsQty;
          b3 = b3.toSlice().concat(signatures[i].rsDesc.toSlice());
          b3 = b3.toSlice().concat('~~~'.toSlice());

        }

        return (transactions, rsDates, rsIdx, rsQty, bytes(b3));

  }
  
  function ResourceAdd(uint _idx, uint _qty, bytes32 _type) returns (bool) {
          rsContributionInfo[msg.sender][_type][_idx].rsQty += _qty;
          return true;
  }


  function ResourceRemove(uint _idx, uint _qty, bytes32 _type) returns (bool) {
          rsContributionInfo[msg.sender][_type][_idx].rsQty -= _qty;
          return true;
  }

  function Contribute(bytes32 _rsType, uint _rsQty, string _rsDesc) returns (bool) {
          address _rsAddress=msg.sender;

          resource memory v=resource(_rsAddress, _rsType, _rsQty, _rsDesc, now, 0);
          rsContributionInfo[_rsAddress][_rsType].push(v);
          uint rsIdx=rsContributionInfo[_rsAddress][_rsType].length - 1;
          rsContributionInfo[_rsAddress][_rsType][rsIdx].rsIdx=rsIdx;

          return true;

  }

  
  function Allocate(address _rsAddress, bytes32 _rsType, uint _rsQty) returns (bool) {

          return rsLogistics.RequestDelivery(_rsAddress, _rsType, 0);

  }

  // function GetResourceQty(address _rsAddress, uint _rsIdx) returns (bool) {
  //
  // }


}
