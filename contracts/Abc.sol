//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.5.11;

library Address {
    
    function isContract(address account) internal view returns (bool) {
        
        uint256 size;
        
        assembly { size := extcodesize(account) }
        return size > 0;
    }


    function toPayable(address account) internal pure returns (address ) {
        return (account);
    }
}

  contract IERC223 {
    
    function name()        public view  returns (string memory);
    function symbol()      public view  returns (string memory);
    function standard()    public view  returns (string memory);
    function decimals()    public view  returns (uint8);
    function totalSupply() public view  returns (uint256);
    
    function balanceOf(address who) public  view returns (uint);
        
    
    function transfer(address to, uint value) public  returns (bool success);
        
    
    function transfer(address to, uint value, bytes memory data) public  returns (bool success);
     
     
    event Transfer(address indexed from, address indexed to, uint value);
    
     
    event TransferData(bytes data);
 }
 
 contract IERC223Recipient {

 struct ERC223TransferInfo
    {
        address token_contract;
        address sender;
        uint256 value;
        bytes   data;
    }
    
    ERC223TransferInfo private tkn;
    
    function tokenReceived(address _from, uint _value, bytes memory _data) public 
    {
        
        tkn.token_contract = msg.sender;
        tkn.sender         = _from;
        tkn.value          = _value;
        tkn.data           = _data;
        
        // ACTUAL CODE
    }

 }
contract ERC223Token is IERC223,IERC223Recipient {

    string  private _name;
    string  private _symbol;
    uint8   private _decimals;
    uint256 private _totalSupply;
    
    
    mapping(address => uint256) public balances; // List of user balances.

    event Transfer(address indexed _from, address indexed _to, uint value);
    event TransferData(bytes _data);


    constructor() public
    {
        _name     = "SBTER";
        _symbol   = "SBT";
        _decimals = 18;
        _totalSupply = 400_000_000; 
    }

    
    function standard() public view  returns (string memory)
    {
        return "erc223";
    }

    function name() public view  returns (string memory)
    {
        return _name;
    }
    
    function symbol() public view  returns (string memory)
    {
        return _symbol;
    }

    
    function decimals() public view  returns (uint8)
    {
        return _decimals;
    }

    
    function totalSupply() public view  returns (uint256)
    {
        return _totalSupply;
    }

    
    
    function balanceOf(address _owner) public view  returns (uint256)
    {
        return balances[_owner];
    }
    
      
    function transfer(address _to, uint _value, bytes memory _data) public  returns (bool success)
    {
        
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        if(Address.isContract(_to)) {
            IERC223Recipient(_to).tokenReceived(msg.sender, _value, _data);
        }
        emit Transfer(msg.sender, _to, _value);
        emit TransferData(_data);
        return true;
    }
    
    
    function transfer(address _to, uint _value) public  returns (bool success)
    {
        bytes memory _empty = hex"00000000";
        balances[msg.sender] = balances[msg.sender] - _value;
        balances[_to] = balances[_to] + _value;
        if(Address.isContract(_to)) {
            IERC223Recipient(_to).tokenReceived(msg.sender, _value, _empty);
        }
        emit Transfer(msg.sender, _to, _value);
        emit TransferData(_empty);
        return true;
    }
}