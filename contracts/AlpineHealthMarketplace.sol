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

    function registerAgent(uint256 agentId, uint256 monthlyPrice) public {
        require(!availableAgents[agentId].exists, "Agent already registered");
        availableAgents[agentId] = Agent({
            owner: msg.sender,
            agentId: agentId,
            monthlyPrice: monthlyPrice,
            exists: true
        });
    }

    function deregisterAgent(uint256 agentId) public {
        require(availableAgents[agentId].exists, "Agent does not exist");
        require(availableAgents[agentId].owner == msg.sender, "Only owner can deregister agent");
        
        delete availableAgents[agentId];
    }
} 