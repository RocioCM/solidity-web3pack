// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

/**
 * @title UsersContract
 * @dev Store, update & retrieve users information
 */
contract UsersContract {
    struct User {
        string name;
        string email;
        uint8 age; // Users age will be in range 0 to 255 years.
        bool enrolledInWeb3Pack; // A funny custom field.
        uint256 timestamp;
    }

    mapping(address => User) private users; // Private but with custom getter/setter.

    /**
     * @dev Get profile of Message Sender
     */
    function getProfile() public view returns (User memory) {
        require(users[msg.sender].timestamp > 0, "User not registered!");
        return users[msg.sender];
    }

    /**
     * @dev Get profile for user with the provided address. User must be registered first.
     */
    function getProfile(address _address) public view returns (User memory) {
        require(users[_address].timestamp > 0, "User not registered!");
        return users[_address];
    }

    /**
     * @dev Register Sender User.
     * User cannot be registered twice. Use updateProfile instead.
     */
    function register(string memory _name, string memory _email, uint8 _age, bool _enrolledInWeb3Pack) public {
        require(users[msg.sender].timestamp == 0, "User already registered!");
        User storage user = users[msg.sender];
        user.name = _name;
        user.email = _email;
        user.age = _age;
        user.enrolledInWeb3Pack = _enrolledInWeb3Pack;
        user.timestamp = block.timestamp;
    }

    /**
     * @dev Update profile of Message Sender. User must be registered first.
     */
    function updateProfile(string memory _name, string memory _email, uint8 _age, bool _enrolledInWeb3Pack) public {
        require(users[msg.sender].timestamp > 0, "User not registered!");
        User storage user = users[msg.sender];
        user.name = _name;
        user.email = _email;
        user.age = _age;
        user.enrolledInWeb3Pack = _enrolledInWeb3Pack;
        user.timestamp = block.timestamp;
    }
}
