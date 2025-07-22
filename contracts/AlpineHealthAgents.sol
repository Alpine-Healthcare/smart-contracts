// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AlpineHealthAgents {
    struct AgentInfo {
        string pdosHash;
        uint256 createdAt;
        bool isActive;
    }

    event AgentCreated(uint256 indexed agentId, address indexed owner, string pdosHash, uint256 createdAt);
    event AgentUpdated(uint256 indexed agentId, address indexed owner, string pdosHash, bool isActive);

    mapping(uint256 => AgentInfo) public agentIdToInfo;
    mapping(address => uint256[]) public ownerToAgentId;
    uint256 public nextAgentId;

    function createAgent(string memory pdosHash) public {
        uint256 agentId = nextAgentId++;
        agentIdToInfo[agentId] = AgentInfo({
            pdosHash: pdosHash,
            createdAt: block.timestamp,
            isActive: true
        });
        ownerToAgentId[msg.sender].push(agentId);
        emit AgentCreated(agentId, msg.sender, pdosHash, block.timestamp);
    }

    function updateAgent(uint256 agentId, string memory pdosHash, bool isActive) public {
        require(_isOwner(msg.sender, agentId), "Not owner");
        AgentInfo storage agent = agentIdToInfo[agentId];
        agent.pdosHash = pdosHash;
        agent.isActive = isActive;
        emit AgentUpdated(agentId, msg.sender, pdosHash, isActive);
    }

    function deleteAgent(uint256 agentId) public {
        require(_isOwner(msg.sender, agentId), "Not owner");
        
        // Remove agent from owner's list
        uint256[] storage agentIds = ownerToAgentId[msg.sender];
        for (uint256 i = 0; i < agentIds.length; i++) {
            if (agentIds[i] == agentId) {
                // Replace with the last element and pop
                agentIds[i] = agentIds[agentIds.length - 1];
                agentIds.pop();
                break;
            }
        }
        
        // Clear agent data
        delete agentIdToInfo[agentId];
    }

    function getAgentById(uint256 agentId) public view returns (AgentInfo memory) {
        return agentIdToInfo[agentId];
    }

    function getAgentsByOwner(address owner) public view returns (uint256[] memory) {
        return ownerToAgentId[owner];
    }

    function _isOwner(address owner, uint256 agentId) internal view returns (bool) {
        uint256[] storage agentIds = ownerToAgentId[owner];
        for (uint256 i = 0; i < agentIds.length; i++) {
            if (agentIds[i] == agentId) {
                return true;
            }
        }
        return false;
    }
} 