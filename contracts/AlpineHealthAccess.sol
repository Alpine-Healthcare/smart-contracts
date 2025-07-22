// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AlpineHealthAccess {
    struct AccessInfo {
        string pdosRoot;
        address computeNode;
        mapping(address => bool) authorizedAccess;
        mapping(address => bool) pendingAccess;
    }

    mapping(address => AccessInfo) public userToAccessInfo;

    // Mapping from compute node address to array of user addresses
    mapping(address => address[]) public computeNodeToUsers;

    // Event emitted when a user's compute node is updated
    event UserComputeNodeUpdated(address indexed userAddress, address indexed oldComputeNode, address indexed newComputeNode);


    function addNewUser(address userAddress, address computeNode) public {
        require(userAddress != address(0), "Invalid user address");
        require(computeNode != address(0), "Invalid compute node address");
        require(userToAccessInfo[userAddress].computeNode == address(0), "User already exists");
        
        userToAccessInfo[userAddress].computeNode = computeNode;
        userToAccessInfo[userAddress].authorizedAccess[userAddress] = true;
        computeNodeToUsers[computeNode].push(userAddress);
    }

    function hasUserAccess(address userAddress) public view returns (bool) {
        return userToAccessInfo[userAddress].authorizedAccess[userAddress];
    }

    function getUserComputeNode(address userAddress) public view returns (address computeNode) {
        return userToAccessInfo[userAddress].computeNode;
    }

    function updateUserComputeNode(address userAddress, address newComputeNode) public {
        require(msg.sender == userAddress, "Only user can update their compute node");
        address oldComputeNode = userToAccessInfo[userAddress].computeNode;
        require(oldComputeNode != address(0), "User does not exist");
        require(newComputeNode != address(0), "Invalid new compute node address");
        require(oldComputeNode != newComputeNode, "New compute node must be different");
        
        // Remove user from old compute node's user list
        address[] storage oldUsers = computeNodeToUsers[oldComputeNode];
        for (uint i = 0; i < oldUsers.length; i++) {
            if (oldUsers[i] == userAddress) {
                oldUsers[i] = oldUsers[oldUsers.length - 1];
                oldUsers.pop();
                break;
            }
        }
        // Add user to new compute node's user list
        computeNodeToUsers[newComputeNode].push(userAddress);
        userToAccessInfo[userAddress].computeNode = newComputeNode;
        emit UserComputeNodeUpdated(userAddress, oldComputeNode, newComputeNode);
    }

    function addAuthorizedAccessForUser(address userAddress, address authorizedUserAddress) public {
        require(msg.sender == userAddress, "Only user can authorize");
        userToAccessInfo[userAddress].authorizedAccess[authorizedUserAddress] = true;
    }

    function addAccessRequestForUser(address userAddress) public {
        userToAccessInfo[userAddress].pendingAccess[msg.sender] = true;
    }

    function approveAccessRequestForUser(address userAddress, address requestingUserAddress) public {
        require(msg.sender == userAddress, "Only user can approve");
        require(userToAccessInfo[userAddress].pendingAccess[requestingUserAddress], "No pending request");
        userToAccessInfo[userAddress].pendingAccess[requestingUserAddress] = false;
        userToAccessInfo[userAddress].authorizedAccess[requestingUserAddress] = true;
    }

    /**
     * @notice Get the PDOS root for a specific user
     * @param userAddress The address of the user
     * @return The PDOS root hash for the user
     */
    function getPDOSRoot(address userAddress) public view returns (string memory) {
        return userToAccessInfo[userAddress].pdosRoot;
    }

    /**
     * @notice Update the PDOS root for a specific user
     * @param userAddress The address of the user
     * @param newPDOSRoot The new PDOS root hash
     */
    function updatePDOSRoot(address userAddress, string memory newPDOSRoot) public {
        require(
            msg.sender == userAddress || 
            msg.sender == userToAccessInfo[userAddress].computeNode || 
            userToAccessInfo[userAddress].authorizedAccess[msg.sender],
            "Only user, compute node, or authorized access can update PDOS root"
        );
        userToAccessInfo[userAddress].pdosRoot = newPDOSRoot;
    }

    /**
     * @notice Get the list of users for a specific compute node
     * @param computeNode The address of the compute node
     * @return The array of user addresses assigned to the compute node
     */
    function getUsersForComputeNode(address computeNode) public view returns (address[] memory) {
        return computeNodeToUsers[computeNode];
    }
} 