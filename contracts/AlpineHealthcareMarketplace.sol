// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

contract AlpineHealthcareMarketplace {

    string marketplacePool;

    struct MarketplaceItem {
        string encryptedAccessKey;
        string encryptedPaymentKey;
        string encryptedMetadata;
        string pdosHashId;
    }

    mapping(address => string) private ownerAddressToMarketplaceDataHashId;
    mapping(address => string) private ownerAddressToFunds;
    mapping(address => MarketplaceItem) private ownerAddressToMarketplaceItem;

    mapping(address => string) private subscriberToEncryptedPaymentKey;
    
    struct Payment {
        string amount;
        string encryptedPaymentRecipient;
    }

    mapping(address => Payment) private unresolvedPayments;

    function addMarketplaceItem(
        string calldata _id,
        string calldata _encryptedAccessKey,
        string calldata _encryptedPaymentKey,
        string calldata _metadata,
        string calldata _pdosHashId
    ) external {}

    function sendPayment(
        string calldata _funds,
        string calldata _encryptedPayment
    ) external {

    }

    function collectPayments() external {}

}
