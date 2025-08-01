// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract AlpineHealthMarketplace {
    struct Agent {
        address owner;
        uint256 agentId;
        uint256 monthlyPrice;
        bool exists;
    }

    mapping(uint256 => Agent) public availableAgents;
    mapping(uint256 => Agent) public pendingAgents;
    uint256[] public availableAgentIds;

    function registerAgent(uint256 agentId, uint256 monthlyPrice) public {
        require(!availableAgents[agentId].exists, "Agent already registered");
        availableAgents[agentId] = Agent({
            owner: msg.sender,
            agentId: agentId,
            monthlyPrice: monthlyPrice,
            exists: true
        });
        availableAgentIds.push(agentId);
    }

    function deregisterAgent(uint256 agentId) public {
        require(availableAgents[agentId].exists, "Agent does not exist");
        require(availableAgents[agentId].owner == msg.sender, "Only owner can deregister agent");
        // Remove agentId from availableAgentIds
        for (uint256 i = 0; i < availableAgentIds.length; i++) {
            if (availableAgentIds[i] == agentId) {
                availableAgentIds[i] = availableAgentIds[availableAgentIds.length - 1];
                availableAgentIds.pop();
                break;
            }
        }
        delete availableAgents[agentId];
    }

    function getAllAvailableAgentIds() public view returns (uint256[] memory) {
        return availableAgentIds;
    }
} 