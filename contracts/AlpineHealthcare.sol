// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

contract AlpineHealthcare {
    /**
     * Tracks compute node information
     */
    mapping(address => bool) private computeNodeIsActive;
    mapping(address => address[]) private computeNodeToUsers;

    /**
     * Tracks user information
     */
    mapping(address => bool) private userIsActive;
    mapping(address => string) private userPDOSRootHash;
    mapping(address => address) private userToComputeNode;
    mapping(address => mapping(address => bool)) private userToMarketplaceItem;

    /**
     * Handle storing encryption keys used by users and compute nodes
     */
    struct EncryptedKeys {
        string dataKey;         // used to encrypt PDOS data
        string marketplaceKey;  // used to encrypt PDOS data for marketplace usage
    }
    // Encrypted data key for each user (encrypted with the user's public key)
    mapping(address => EncryptedKeys) private userToEncryptionKeys;

    /**
     * PDOS Functions
     */
    /**
     * @notice Updates the PDOS root for the caller.
     */
    function updatePDOSRoot(address user, string calldata _newHash) external {
        userPDOSRootHash[user] = _newHash;
    }

    /**
     * @notice Returns the PDOS root for a specific user.
     */
    function getPDOSRoot(address user) external view returns (string memory) {
        return userPDOSRootHash[user];
    }

    /**
     * User Management Functions
     */
    /**
     * @notice Checks if a user is active.
     */
    function checkIsActive(address user) external view returns (bool) {
        return userIsActive[user];
    }

    /**
     * Offboard a user 
     */
    /**
     * @notice Checks if a user is active.
     */
    function offboardUser(address user) external {
        delete userToEncryptionKeys[user];
        delete userPDOSRootHash[user];
        delete userIsActive[user];
    }

    /**
     * @notice Onboards a user by marking them active and storing user keys.
     * @param _pdosHash PDOS root hash
     * @param _encryptedDataKey The data key encrypted to the user's public key
     */
    function onboard(string calldata _pdosHash, string calldata _encryptedDataKey) external {
        userIsActive[msg.sender] = true;
        userPDOSRootHash[msg.sender] = _pdosHash;

        // Store the encrypted data key (marketplaceKey left empty for now)
        userToEncryptionKeys[msg.sender] = EncryptedKeys(_encryptedDataKey, "");
    }

    /**
     * @notice Returns the user’s own encrypted data keys.
     */
    function hasUserAccess() external pure returns (bool) {
        return true;
    }

    /**
     * @notice Returns the user’s own encrypted data keys.
     */
    function getUserEncryptedDataKeys(address user) external view returns (EncryptedKeys memory) {
        require(msg.sender == user, "Access denied");
        return userToEncryptionKeys[user];
    }

    /**
     * Compute Node Management Functions
     */
    /**
     * @notice Adds or updates a compute node's access for the caller.
     */
    function addComputeNodeAccessForUser(address computeNode) external {
        require(userIsActive[msg.sender], "User not active");
        userToComputeNode[msg.sender] = computeNode;

        // Mark the user as authorized for this compute node
        computeNodeToUsers[computeNode].push(msg.sender);
    }

     /**
     * Compute Node Management Functions
     */
    /**
     * @notice Adds or updates a compute node's access for the caller.
     */
    function getUsersComputeNode(address user) external view returns (address){
        return userToComputeNode[user];
    }

    /**
     * Compute Node Management Functions
     */
    /**
     * @notice Adds or updates a compute node's access for the caller.
     */
    function getUsersForComputeNode(address computeNode) external view returns (address[] memory){
        return computeNodeToUsers[computeNode];
    }

    /**
     * @notice Revokes a compute node's access for the caller.
     */
    function removeComputeNodeAccessForUser(address computeNode) external {
        require(userIsActive[msg.sender], "User not active");
        require(userToComputeNode[msg.sender] == computeNode, "Compute node not linked to user");

        // Revoke authorization
        //computeNodeToUsers[computeNode][msg.sender] = false;
    }

    /**
     * Marketplace Functions
     * 
     * 1. postPayment to marketplace
     * 2. Send transaction to lit action
     * 3. Lit action listener picks up signed transaction, pays out to marketplace item owner
     */
    function subscribeToMarketplaceItem(address computeNode) external {
        // Implementation placeholder
    }
}
