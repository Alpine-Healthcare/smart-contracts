// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

contract SaagBets {
    // Struct to store metrics for each betting event.
    struct BettingEvent {
        uint totalPool; // Total funds added for the event.
        uint betCount;  // Number of bets placed.
    }

    // Mapping from event ID to its BettingEvent data.
    mapping(uint => BettingEvent) public events;

    // Emitted when a bet is placed.
    event BetPlaced(
        uint indexed eventId,
        address indexed bettor,
        uint amount,
        uint newTotalPool,
        uint newBetCount
    );

    /**
     * @notice Place a bet on a specific event by sending Ether.
     * @param eventId A unique identifier for the betting event.
     *
     * Requirements:
     * - The bet amount (msg.value) must be greater than zero.
     *
     * When a bet is placed, the function updates the event's total pool
     * and increments the bet count.
     */
    function placeBet(uint eventId) external payable {
        require(msg.value > 0, "Bet amount must be greater than zero");

        // Retrieve the event data (or initialize if not already present)
        BettingEvent storage bettingEvent = events[eventId];

        // Update metrics for the event.
        bettingEvent.totalPool += msg.value;
        bettingEvent.betCount++;

        // Emit an event for off-chain tracking or transparency.
        emit BetPlaced(eventId, msg.sender, msg.value, bettingEvent.totalPool, bettingEvent.betCount);
    }
}
