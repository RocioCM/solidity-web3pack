// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 * @custom:dev-run-script ./scripts/deploy_with_ethers.ts
 */
contract VaultBase {
    string private tokenName;
    string private tokenSymbol;
    uint256 private tokenTotalSupply;
    mapping(address user => uint256 balance) private balances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Mint(address indexed to, uint256 value);
    event Burn(address indexed from, uint256 value);

    constructor(string memory _name, string memory _symbol) {
        tokenTotalSupply = 0;
        tokenName = _name;
        tokenSymbol = _symbol;
    }

    function name() public view returns (string memory) {
        return tokenName;
    }

    function symbol() public view returns (string memory) {
        return tokenSymbol;
    }

    function totalSupply() public view returns (uint256) {
        return tokenTotalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function transfer(address _from, address _to, uint256 _value) internal {
        require(_value > 0, "Value cannot be 0");
        require(balances[_from] >= _value, "Insufficient balance to transfer");

        // Update sender balance first.
        balances[_from] = balances[_from] - _value;

        // Update receiver balance then.
        balances[_to] = balances[_to] + _value;

        emit Transfer(_from, _to, _value);
    }

    function mint(address _to, uint256 _value) internal {
        require(_value > 0, "Value cannot be 0");

        // Update total supply.
        tokenTotalSupply = tokenTotalSupply + _value;

        // Update receiver's value.
        balances[_to] = balances[_to] + _value;

        emit Mint(_to, _value);
    }

    function burn(address _to, uint256 _value) internal {
        require(_value > 0, "Value cannot be 0");
        require(balances[_to] >= _value, "Insufficient balance to burn");
        require(tokenTotalSupply >= _value, "Insufficient supply to burn");

        // Update total supply.
        tokenTotalSupply = tokenTotalSupply - _value;

        // Update address' balance.
        balances[_to] = balances[_to] - _value;

        emit Burn(_to, _value);
    }
}

contract VaultManager is VaultBase("RocioToken", "ROT") {
    event Deposit(address indexed _from, uint256 _value);
    event Withdraw(address indexed _from, uint256 _value);

    function balance() public view returns (uint256) {
        return balanceOf(msg.sender);
    }

    function deposit() public payable {
        require(msg.value > 0, "Must deposit more than 0 ETH");

        address _to = msg.sender;
        uint256 _amount = msg.value;

        // Mint that will revert if preconditions failed.
        mint(_to, _amount);

        emit Deposit(_to, _amount);
    }

    function withdraw(uint256 _amount) public {
        require(_amount > 0, "Must withdraw more than 0 ETH");

        address payable _to = payable(msg.sender);

        // Burn that will revert if preconditions failed.
        burn(_to, _amount);

        // Send funds to user if burn is not reverted.
        (bool success, ) = _to.call{ value: _amount }("");
        require(success, "Failed to send Ether");

        emit Withdraw(_to, _amount);
    }

    // Fallback to avoid users loosing funds.
    receive() external payable {
        deposit();
    }
}
