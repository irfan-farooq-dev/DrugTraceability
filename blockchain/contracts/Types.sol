// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

/**
 * @title Types
 * @dev Custom data types used throughout the Drug Supply Chain
 */
library Types {
    /// @notice Different roles a user can have in the supply chain
    enum UserRole {
        Manufacturer, // 0
        Supplier, // 1
        Vendor, // 2
        Customer // 3
    }

    /// @notice Details of a registered user
    struct UserDetails {
        UserRole role;
        address id_;
        string name;
        string email;
    }

    /// @notice Categories of product types
    enum ProductType {
        BCG, // 0
        RNA, // 1
        MRNA, // 2
        MMR, // 3
        NasalFlu // 4
    }

    /// @notice Product status in the supply chain
    enum ProductStatus {
        Created, // 0
        InTransit, // 1
        Delivered, // 2
        Verified // 3
    }

    /// @notice History entry representing an action taken by a user
    struct UserHistory {
        address id_; // Ethereum address of the user
        uint256 date; // Timestamp when action was taken
    }

    /// @notice Full lifecycle history of a product
    struct ProductHistory {
        UserHistory manufacturer;
        UserHistory supplier;
        UserHistory vendor;
        UserHistory[] customers;
    }

    /// @notice Complete product data
    struct Product {
        string name;
        string manufacturerName;
        address manufacturer;
        uint256 manDateEpoch;
        uint256 expDateEpoch;
        bool isInBatch;
        uint256 batchCount;
        string barcodeId;
        string productImage;
        ProductType productType;
        string scientificName;
        string usage;
        string[] composition;
        string[] sideEffects;
        bytes32 id_;
        address from_;
        address to_;
        address owner;
        ProductStatus status;
    }
}
