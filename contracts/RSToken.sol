/*
This Token Contract implements the standard token functionality (https://github.com/ethereum/EIPs/issues/20) as well as the following OPTIONAL extras intended for use by humans.

In other words. This is intended for deployment in something like a Token Factory or Mist wallet, and then used by humans.
Imagine coins, currencies, shares, voting weight, etc.
Machine-based, rapid creation of many tokens would not necessarily need these extra features or will be minted in other manners.

1) Initial Finite Supply (upon creation one specifies how much is minted).
2) In the absence of a token registry: Optional Decimal, Symbol & Name.
3) Optional approveAndCall() functionality to notify a contract if an approval() has occurred.

.*/
pragma solidity ^0.4.11;

import "./token/MintableToken.sol";
import "./math/SafeMath.sol";
import "./ConvertLib.sol";


contract RSToken is MintableToken {
    using ConvertLib for *;

    string public name;                   //name
    uint8  public decimals;               //There could 1000 base units with 3 decimals. 
    string public symbol;                 //An identifier: eg GOODWILL
    string public version = 'RSTOKEN_0.01';       //GOODWILL Coin version
    address wallet;

    enum Types {
        Transfer,
        Reserve,
        ReverseReserve,
        ReleaseReserve
    }

    event Reserve(address indexed _from, address indexed _to, uint256 _value);
    event ReleaseReserve(address indexed _from, address indexed _to, uint256 _value);
    event ReverseReserve(address indexed _from, address indexed _to, uint256 _value);
      
    struct transaction {
    
      address sender;
      address recipient;
      uint date;
      uint amount;
      Types status;
            
    }
  
    mapping (address => transaction[])   public transactions;
    mapping (address => uint256) public  tokensReceived;
    mapping (address => uint256) public  tokensBought;
    mapping (address => uint256) public  tokensReserved;
    mapping (address => uint256) public  tokensSpent;
    mapping (address => uint256) public  tokensSoldInWei;
    mapping (address => string)  public  userName;
    mapping (address => uint)    public  userId;
    
    function RSToken(uint256 _tokens, uint256 _rate, address[] adminAddress) 
        Administered(adminAddress)
        MintableToken(_rate)
    {
    
        admins  = adminAddress;    
        wallet  = admins[0];
        mint(wallet, _tokens);        
        
        name = 'RSATKN';                               // Set the name for display purposes
        decimals = 0;
        symbol = 'RSATKN';               
        
        
    }

    function spend(address user, uint tokens) onlyAdmin returns (uint){
        assert(isAdmin[msg.sender]);
    
        balances[wallet] =ConvertLib.safeAdd(balances[wallet], tokens);
        tokensReceived[wallet] =ConvertLib.safeAdd(tokensReceived[wallet], tokens);
        balances[user]=ConvertLib.safeSub(balances[user], tokens);
        Transfer(user, wallet, tokens);
        
        return (tokens);
        
    }
    
    
    function adminTransferFrom(address _user, address _to, uint _value) onlyAdmin returns (bool) {    
        assert(isAdmin[msg.sender]);
        
        if (balances[_user] >= _value && _value >= 0) {
            if (_to > 0 && _value > 0) {
                balances[_user] = ConvertLib.safeSub(balances[_user], _value);
                balances[_to] = ConvertLib.safeAdd(balances[_to], _value);
                tokensReceived[_to] = ConvertLib.safeAdd(tokensReceived[_to], _value);

                transaction memory v=transaction(_user, _to, now, _value, Types.Transfer);
                transactions[_user].push(v);
                transactions[_to].push(v);

                Transfer(_user, _to, _value);
                return true;
            }
            if (_value == 0) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
        
    }
    
    function adminReserveFrom(address _user, address _to, uint _value) onlyAdmin returns (bool) {    
        assert(isAdmin[msg.sender]);
        
        if (balances[_user] >= _value && _value >= 0) {
            if (_to > 0 && _value > 0) {
                balances[_user] = ConvertLib.safeSub(balances[_user], _value);
                
                tokensReserved[_user] = ConvertLib.safeAdd(tokensReserved[_user], _value);
                tokensReserved[_to] = ConvertLib.safeAdd(tokensReserved[_to], _value);

                transaction memory v=transaction(_user, _to, now, _value, Types.Reserve);
                transactions[_user].push(v);
                transactions[_to].push(v);

                Reserve(_user, _to, _value);
                return true;
            }
            if (_value == 0) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
        
    }
    
    function adminReleaseReserveFrom(address _user, address _to, uint _value) onlyAdmin returns (bool) {    
        assert(isAdmin[msg.sender]);
        
        if (tokensReserved[_user] >= _value && _value >= 0) {
            if (_to > 0 && _value > 0) {
                tokensReserved[_user] = ConvertLib.safeSub(tokensReserved[_user], _value);
                tokensReserved[_to] = ConvertLib.safeSub(tokensReserved[_to], _value);
                
                balances[_to] = ConvertLib.safeAdd(balances[_to], _value);

                transaction memory v=transaction(_user, _to, now, _value, Types.ReleaseReserve);
                transactions[_user].push(v);
                transactions[_to].push(v);

                ReleaseReserve(_user, _to, _value);
                return true;
            }
            if (_value == 0) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
        
    }
    
    function adminReverseReserveFrom(address _user, address _to, uint _value) onlyAdmin returns (bool) {    
        assert(isAdmin[msg.sender]);
        
        if (tokensReserved[_user] >= _value && _value >= 0) {
            if (_to > 0 && _value > 0) {
                tokensReserved[_user] = ConvertLib.safeSub(tokensReserved[_user], _value);
                tokensReserved[_to] = ConvertLib.safeSub(tokensReserved[_to], _value);
                
                balances[_user] = ConvertLib.safeAdd(balances[_user], _value);

                transaction memory v=transaction(_user, _to, now, _value, Types.ReverseReserve);
                transactions[_user].push(v);
                transactions[_to].push(v);

                ReverseReserve(_user, _to, _value);
                return true;
            }
            if (_value == 0) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
        
    }
    
    function adminTransfer(address user, uint tokens, uint id,  string name) onlyAdmin returns (uint, uint) {    
        assert(isAdmin[msg.sender]);
        
        userName[user]=name;
        userId[user]=id;
        
        balances[user] = ConvertLib.safeAdd(balances[user], tokens);
        tokensReceived[user] = ConvertLib.safeAdd(tokensReceived[user], tokens);
        
        transaction memory v=transaction(msg.sender, user, now, tokens, Types.Transfer);
        transactions[msg.sender].push(v);
        transactions[user].push(v);
        Transfer(msg.sender, user, tokens);
        
        uint eth_balance=convertToWei( balances[user] );
        return (balances[user], eth_balance);
    }
    
    function setWallet(address _wallet) onlyAdmin returns (bool) {
        wallet=_wallet;
        return true;                
    }
    
    function gcAuth(address user, string name, uint id) onlyAdmin payable returns (uint, uint, uint) {    
        assert(isAdmin[msg.sender]);
        
        if (tokensBought[user] < 5 && balances[user] < 5) {
            uint tokensToBuy = 5;            
            tokensBought[user] += tokensToBuy;
            userName[user]=name;
            userId[user]=id;
            balances[user] = ConvertLib.safeAdd(balances[user], tokensToBuy);
            balances[wallet] = ConvertLib.safeSub(balances[wallet], tokensToBuy);
            Transfer(wallet, user, tokensToBuy);
            
            transaction memory v=transaction(msg.sender, user, now, tokensToBuy, Types.Transfer);
            transactions[msg.sender].push(v);
            transactions[user].push(v);
        }
    
        uint eth_balance=convertToWei( balances[user]);
        return (balances[user], eth_balance, tokensReserved[user]);
    
    }
  
    function getBalanceInEth(address addr) returns(uint){
		return convertToWei( balances[addr] );
	}

	function getBalance(address addr) returns(uint) {
		return (balances[addr]);
	}
	
	function getTokensReceived(address addr) returns(uint) {
		return (tokensReceived[addr]);
	}
	
	
	
	function transfer(address _to, uint256 _value) returns (bool success) {
        	
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] = ConvertLib.safeSub(balances[msg.sender], _value);
            balances[_to] = ConvertLib.safeAdd(balances[_to], _value);
            tokensReceived[_to] = ConvertLib.safeAdd(tokensReceived[_to], _value);
            Transfer(msg.sender, _to, _value);

            transaction memory v=transaction(msg.sender, _to, now, _value, Types.Transfer);
            transactions[msg.sender].push(v);
            transactions[_to].push(v);

            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] = ConvertLib.safeAdd(balances[_to], _value);
            balances[_from] = ConvertLib.safeSub(balances[_from], _value);
            tokensReceived[_to] = ConvertLib.safeAdd(tokensReceived[_to], _value);
            allowed[_from][msg.sender] = ConvertLib.safeSub(allowed[_from][msg.sender], _value);
            Transfer(_from, _to, _value);
            transaction memory v=transaction(_from, _to, now, _value, Types.Transfer);
            transactions[_from].push(v);
            transactions[_to].push(v);
            return true;
        } else { return false; }
    }
    

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
    
    // @return true if the transaction can buy tokens
    function validPurchase() internal constant returns (bool) {
        bool nonZeroPurchase = msg.value != 0;
        return nonZeroPurchase;
    }

    // fallback function can be used to buy tokens
    function () payable {
        buyTokens(msg.sender);
    }

    // low level token purchase function
    function buyTokensFrom(address from, address beneficiary) payable {
        require(beneficiary != 0x0);
        require(validPurchase());
    
        uint256 weiAmount = msg.value;

        // calculate token amount to be created
        uint256 tokens = convertToToken(weiAmount);
    
        // update state        
        if (transferFrom(from, beneficiary, tokens)) {
            tokensBought[beneficiary] = ConvertLib.safeAdd(tokensBought[beneficiary], tokens);
            tokensSoldInWei[from] = ConvertLib.safeAdd(tokensSoldInWei[from], weiAmount);
            
            forwardFunds(from);
        }        
        
    }
    
    function buyTokens(address beneficiary) payable {
        require(beneficiary != 0x0);
        require(validPurchase());
        
        uint256 weiAmount = msg.value;

        // calculate token amount to be created
        uint256 tokens = convertToToken(weiAmount);
    
        if (tokens > 0) {
        
            tokensBought[beneficiary] = ConvertLib.safeAdd(tokensBought[beneficiary], tokens);
            
            mint(beneficiary, tokens);
            
            forwardFunds(wallet);
        
        }        
        
    }
    
    function convertToWei(uint256 amount) returns (uint256)
    {
		return amount.mul(rate);
    }

    function convertToToken(uint256 amount) returns (uint256)
    {
		return amount.div(rate);
    }

    // send ether to the fund collection wallet
    // override to create custom fund forwarding mechanisms
    function forwardFunds(address wallet) internal {
        wallet.transfer(msg.value);
    }
    
    function userDetails(address _user) constant returns (uint, uint, uint) {

        return (balances[_user], tokensReceived[_user], transactions[_user].length);

    }

}
