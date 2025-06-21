// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

contract AlpineHealth {
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
    // Maps agent ID -> AgentInfo
    mapping(uint256 => AgentInfo) private agentIdToInfo;
    // Maps agent ID -> user address
    mapping(uint256 => address) private agentIdToUser;
    // Tracks number of agents per user for ID assignment
    mapping(address => uint256) private userAgentCount;

    // Array to track all users who have created agents
    address[] private agentCreators;
    // Mapping to check if a user is already in the agentCreators array
    mapping(address => bool) private isAgentCreator;

    struct UserInitInfo {
        address user;
        address computeNode;
        string pdosRootHash;
        uint256[] agentIds;  // Array of agent IDs
        AgentInfo[] agentInfos; 
    }

    constructor(UserInitInfo[] memory _initialUsers) {
        for (uint256 i = 0; i < _initialUsers.length; i++) {
            UserInitInfo memory userInfo = _initialUsers[i];
            require(userInfo.user != address(0), "User address cannot be zero");
            require(userInfo.computeNode != address(0), "Compute node address cannot be zero");
            require(userInfo.agentIds.length == userInfo.agentInfos.length, "Agent IDs and infos arrays must have same length");
            
            // Initialize user
            userIsActive[userInfo.user] = true;
            userPDOSRootHash[userInfo.user] = userInfo.pdosRootHash;
            
            // Initialize compute node
            computeNodeIsActive[userInfo.computeNode] = true;
            
            // Link user to compute node
            userToComputeNode[userInfo.user] = userInfo.computeNode;
            computeNodeToUsers[userInfo.computeNode].push(userInfo.user);
            
            // Initialize agents for the user
            for (uint256 j = 0; j < userInfo.agentInfos.length; j++) {
                uint256 agentId = userInfo.agentIds[j];
                AgentInfo memory agent = userInfo.agentInfos[j];
                
                // Store agent information
                userAgents[userInfo.user][agentId] = agent;
                agentIdToInfo[agentId] = agent;
                agentIdToUser[agentId] = userInfo.user;
                
                // Update userAgentCount to be at least agentId + 1
                if (userAgentCount[userInfo.user] <= agentId) {
                    userAgentCount[userInfo.user] = agentId + 1;
                }
            }
            
            // Add user to agent creators if they have any agents
            if (userInfo.agentInfos.length > 0) {
                agentCreators.push(userInfo.user);
                isAgentCreator[userInfo.user] = true;
            }
        }
    }

    /**
     * PDOS Functions
     */
    /**
     * @notice Updates the PDOS root for the caller.
     */
    function updatePDOSRoot(address user, string calldata _newHash) external {
        require(userIsActive[user], "User not active");
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
     * @notice Onboards a user by marking them active and storing user keys.
     * @param _pdosHash PDOS root hash
     */
    function onboard(string calldata _pdosHash) external {
        userIsActive[msg.sender] = true;
        userPDOSRootHash[msg.sender] = _pdosHash;
    }

    /**
     * @notice Returns if the requesting address has access to the user's PDOS tree.
     */
    function hasUserAccess(address user) external view returns (bool) {
        return true;
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
        userToComputeNode[msg.sender] = address(0);
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
        AgentInfo memory newAgent = AgentInfo({
            ipfsHash: _ipfsHash,
            createdAt: block.timestamp,
            isActive: true,
            isPublic: _isPublic
        });
        
        userAgents[msg.sender][agentId] = newAgent;
        agentIdToInfo[agentId] = newAgent;
        agentIdToUser[agentId] = msg.sender;
        
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
        
        AgentInfo memory updatedAgent = AgentInfo({
            ipfsHash: _ipfsHash,
            createdAt: userAgents[msg.sender][_agentId].createdAt,
            isActive: true,
            isPublic: _isPublic
        });
        
        userAgents[msg.sender][_agentId] = updatedAgent;
        agentIdToInfo[_agentId] = updatedAgent;
    }

    /**
     * @notice Deactivates an existing health agent
     * @param _agentId The ID of the agent to deactivate
     */
    function deactivateAgent(uint256 _agentId) external {
        require(userIsActive[msg.sender], "User not active");
        require(_agentId < userAgentCount[msg.sender], "Agent does not exist");
        
        userAgents[msg.sender][_agentId].isActive = false;
        agentIdToInfo[_agentId].isActive = false;
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
        delete agentIdToInfo[_agentId];
        delete agentIdToUser[_agentId];
    }

    /**
     * @notice Gets agent information directly by agent ID
     * @param _agentId The ID of the agent
     * @return Agent information and owner address
     */
    function getAgentInfoById(uint256 _agentId) external view returns (AgentInfo memory, address) {
        require(agentIdToUser[_agentId] != address(0), "Agent does not exist");
        return (agentIdToInfo[_agentId], agentIdToUser[_agentId]);
    }
}
