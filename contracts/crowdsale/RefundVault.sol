pragma solidity ^0.4.11;

import '../math/SafeMath.sol';
import '../admin/Administered.sol';

/**
 * @title RefundVault
 * @dev This contract is used for storing funds while a crowdsale
 * is in progress. Supports refunding the money if crowdsale fails,
 * and forwarding it if crowdsale is successful.
 */
contract RefundVault is Administered {
  using SafeMath for uint256;

  enum State { Active, Refunding, Closed }

  mapping (address => uint256) public deposited;
  address public wallet;
  State public state;

  event Closed();
  event RefundsEnabled();
  event Refunded(address indexed beneficiary, uint256 weiAmount);

  function RefundVault(address _wallet, address[] adminAddress)
    Administered(adminAddress)
  {
    require(_wallet != 0x0);
    wallet = _wallet;
    state = State.Active;
  }

  function deposit(address investor) onlyAdmin payable {
    require(state == State.Active);
    deposited[investor] = deposited[investor].add(msg.value);
  }

  function close() onlyAdmin {
    require(state == State.Active);
    state = State.Closed;
    Closed();
    wallet.transfer(this.balance);
  }

  function enableRefunds() onlyAdmin {
    require(state == State.Active);
    state = State.Refunding;
    RefundsEnabled();
  }

  function refund(address investor) {
    require(state == State.Refunding);
    uint256 depositedValue = deposited[investor];
    deposited[investor] = 0;
    investor.transfer(depositedValue);
    Refunded(investor, depositedValue);
  }
}
