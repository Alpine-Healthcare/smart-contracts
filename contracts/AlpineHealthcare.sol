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
     * Health Agent information
     */
    struct AgentInfo {
        string ipfsHash;
        uint256 createdAt;
        bool isActive;
        bool isPublic;  // Added flag to indicate if agent is publicly visible
    }
    
    // Maps user address -> agent ID -> AgentInfo
    mapping(address => mapping(uint256 => AgentInfo)) private userAgents;
    // Tracks number of agents per user for ID assignment
    mapping(address => uint256) private userAgentCount;

    /**
     * Handle storing encryption keys used by users and compute nodes
     */
    struct EncryptedKeys {
        string dataKey;         // used to encrypt PDOS data
        string marketplaceKey;  // used to encrypt PDOS data for marketplace usage
    }
    // Encrypted data key for each user (encrypted with the user's public key)
    mapping(address => EncryptedKeys) private userToEncryptionKeys;

    // Array to track all users who have created agents
    address[] private agentCreators;
    // Mapping to check if a user is already in the agentCreators array
    mapping(address => bool) private isAgentCreator;

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
     * @notice Returns the user's own encrypted data keys.
     */
    function hasUserAccess() external pure returns (bool) {
        return true;
    }

    /**
     * @notice Returns the user's own encrypted data keys.
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

    /**
     * Health Agent Management Functions
     */
    
    /**
     * @notice Creates a new health agent for the user
     * @param _ipfsHash IPFS hash of the agent data
     * @param _isPublic Flag indicating if the agent should be public
     * @return agentId The ID of the newly created agent
     */
    function createAgent(string calldata _ipfsHash, bool _isPublic) external returns (uint256) {
        require(userIsActive[msg.sender], "User not active");
        
        // Add user to agentCreators array if they haven't created an agent before
        if (!isAgentCreator[msg.sender]) {
            agentCreators.push(msg.sender);
            isAgentCreator[msg.sender] = true;
        }
        
        uint256 agentId = userAgentCount[msg.sender];
        userAgents[msg.sender][agentId] = AgentInfo({
            ipfsHash: _ipfsHash,
            createdAt: block.timestamp,
            isActive: true,
            isPublic: _isPublic
        });
        
        userAgentCount[msg.sender]++;
        return agentId;
    }

    /**
     * @notice Updates an existing health agent
     * @param _agentId The ID of the agent to update
     * @param _ipfsHash New IPFS hash of the agent data
     * @param _isPublic New public visibility status
     */
    function updateAgent(uint256 _agentId, string calldata _ipfsHash, bool _isPublic) external {
        require(userIsActive[msg.sender], "User not active");
        require(_agentId < userAgentCount[msg.sender], "Agent does not exist");
        require(userAgents[msg.sender][_agentId].isActive, "Agent is not active");
        
        userAgents[msg.sender][_agentId].ipfsHash = _ipfsHash;
        userAgents[msg.sender][_agentId].isPublic = _isPublic;
    }

    /**
     * @notice Deactivates an existing health agent
     * @param _agentId The ID of the agent to deactivate
     */
    function deactivateAgent(uint256 _agentId) external {
        require(userIsActive[msg.sender], "User not active");
        require(_agentId < userAgentCount[msg.sender], "Agent does not exist");
        
        userAgents[msg.sender][_agentId].isActive = false;
    }

    /**
     * @notice Gets information about a specific agent
     * @param _user The address of the user who owns the agent
     * @param _agentId The ID of the agent
     * @return Agent information
     */
    function getAgentInfo(address _user, uint256 _agentId) external view returns (AgentInfo memory) {
        require(_agentId < userAgentCount[_user], "Agent does not exist");
        return userAgents[_user][_agentId];
    }

    /**
     * @notice Gets the number of agents a user has created
     * @param _user The address of the user
     * @return Number of agents
     */
    function getUserAgentCount(address _user) external view returns (uint256) {
        return userAgentCount[_user];
    }
    
    /**
     * @notice Gets all active agents for a specific user
     * @param _user The address of the user
     * @return agentIds Array of active agent IDs
     * @return agentInfos Array of active agent information
     */
    function getActiveAgents(address _user) external view returns (uint256[] memory agentIds, AgentInfo[] memory agentInfos) {
        uint256 totalCount = userAgentCount[_user];
        
        // First, count active agents
        uint256 activeCount = 0;
        for (uint256 i = 0; i < totalCount; i++) {
            if (userAgents[_user][i].isActive) {
                activeCount++;
            }
        }
        
        // Initialize arrays with the correct size
        agentIds = new uint256[](activeCount);
        agentInfos = new AgentInfo[](activeCount);
        
        // Fill arrays with active agent data
        uint256 currentIndex = 0;
        for (uint256 i = 0; i < totalCount; i++) {
            if (userAgents[_user][i].isActive) {
                agentIds[currentIndex] = i;
                agentInfos[currentIndex] = userAgents[_user][i];
                currentIndex++;
            }
        }
        
        return (agentIds, agentInfos);
    }

    /**
     * @notice Gets all public active agents across all users
     * @return userAddresses Array of user addresses corresponding to each agent
     * @return agentIds Array of active agent IDs
     * @return agentInfos Array of active agent information
     */
    function getAllPublicActiveAgents() external view returns (
        address[] memory userAddresses,
        uint256[] memory agentIds,
        AgentInfo[] memory agentInfos
    ) {
        // First count total public active agents across all users
        uint256 totalActiveCount = 0;
        for (uint256 userIndex = 0; userIndex < agentCreators.length; userIndex++) {
            address user = agentCreators[userIndex];
            uint256 totalCount = userAgentCount[user];
            
            for (uint256 i = 0; i < totalCount; i++) {
                if (userAgents[user][i].isActive && userAgents[user][i].isPublic) {
                    totalActiveCount++;
                }
            }
        }
        
        // Initialize arrays with the correct size
        userAddresses = new address[](totalActiveCount);
        agentIds = new uint256[](totalActiveCount);
        agentInfos = new AgentInfo[](totalActiveCount);
        
        // Fill arrays with public active agent data from all users
        uint256 currentIndex = 0;
        for (uint256 userIndex = 0; userIndex < agentCreators.length; userIndex++) {
            address user = agentCreators[userIndex];
            uint256 totalCount = userAgentCount[user];
            
            for (uint256 i = 0; i < totalCount; i++) {
                if (userAgents[user][i].isActive && userAgents[user][i].isPublic) {
                    userAddresses[currentIndex] = user;
                    agentIds[currentIndex] = i;
                    agentInfos[currentIndex] = userAgents[user][i];
                    currentIndex++;
                }
            }
        }
        
        return (userAddresses, agentIds, agentInfos);
    }

    /**
     * @notice Gets all agents (active and inactive) for a specific user
     * @param _user The address of the user
     * @return agentIds Array of all agent IDs
     * @return agentInfos Array of all agent information
     */
    function getAllUserAgents(address _user) external view returns (uint256[] memory agentIds, AgentInfo[] memory agentInfos) {
        uint256 totalCount = userAgentCount[_user];
        
        // Initialize arrays with the total size
        agentIds = new uint256[](totalCount);
        agentInfos = new AgentInfo[](totalCount);
        
        // Fill arrays with all agent data
        for (uint256 i = 0; i < totalCount; i++) {
            agentIds[i] = i;
            agentInfos[i] = userAgents[_user][i];
        }
        
        return (agentIds, agentInfos);
    }

    /**
     * @notice Deletes an existing health agent
     * @param _agentId The ID of the agent to delete
     */
    function deleteAgent(uint256 _agentId) external {
        require(userIsActive[msg.sender], "User not active");
        require(_agentId < userAgentCount[msg.sender], "Agent does not exist");
        
        // Remove the agent by deleting the AgentInfo from storage
        delete userAgents[msg.sender][_agentId];
    }
}
