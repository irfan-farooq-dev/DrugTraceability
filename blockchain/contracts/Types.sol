// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

/**
 * @title Types
 * @dev Custom data types used throughout the Drug Supply Chain
 */
library Types {
    enum UserRole {
        Manufacturer, // 0
        Supplier, // 1
        Vendor, // 2
        Customer // 3
    }

    struct UserDetails {
        UserRole role;
        address id_;
        string name;
        string email;
    }

    enum ProductType {
        BCG, // 0
        RNA, // 1
        MRNA, // 2
        MMR, // 3
        NasalFlu // 4
    }

    struct UserHistory {
        address id_; // Ethereum address of the user
        uint256 date; // Timestamp (epoch UTC) when action was taken (added/purchased)
    }

    struct ProductHistory {
        UserHistory manufacturer;
        UserHistory supplier;
        UserHistory vendor;
        UserHistory[] customers;
    }

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
    }
}
