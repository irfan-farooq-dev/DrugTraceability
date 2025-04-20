// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import "./Types.sol";

/**
 * @title Products
 * @dev Manages the lifecycle of products in the supply chain
 */
contract Products {
    Types.Product[] internal products;
    mapping(string => Types.Product) internal product;
    mapping(address => string[]) internal userLinkedProducts;
    mapping(string => Types.ProductHistory) internal productHistory;

    // Events
    event NewProduct(
        string name,
        string manufacturerName,
        string scientificName,
        string barcodeId,
        uint256 manDateEpoch,
        uint256 expDateEpoch
    );

    event ProductOwnershipTransfer(
        string name,
        string manufacturerName,
        string scientificName,
        string barcodeId,
        string buyerName,
        string buyerEmail
    );

    // Returns all products owned by msg.sender
    function getUserProducts() internal view returns (Types.Product[] memory) {
        string[] memory ids = userLinkedProducts[msg.sender];
        Types.Product[] memory myProducts = new Types.Product[](ids.length);
        for (uint256 i = 0; i < ids.length; i++) {
            myProducts[i] = product[ids[i]];
        }
        return myProducts;
    }

    // Get specific product details and its full history
    function getSpecificProduct(
        string memory barcodeId
    )
        internal
        view
        returns (Types.Product memory, Types.ProductHistory memory)
    {
        return (product[barcodeId], productHistory[barcodeId]);
    }

    // Adds a new product to the blockchain
    function addAProduct(
        Types.Product memory product_,
        uint256 currentTime
    ) internal productNotExists(product_.barcodeId) {
        require(
            product_.manufacturer == msg.sender,
            "Only manufacturer can add"
        );
        products.push(product_);
        product[product_.barcodeId] = product_;
        productHistory[product_.barcodeId].manufacturer = Types.UserHistory({
            id_: msg.sender,
            date: currentTime
        });
        userLinkedProducts[msg.sender].push(product_.barcodeId);

        emit NewProduct(
            product_.name,
            product_.manufacturerName,
            product_.scientificName,
            product_.barcodeId,
            product_.manDateEpoch,
            product_.expDateEpoch
        );
    }

    // Transfers ownership from current user to next role
    function sell(
        address buyer,
        string memory barcodeId,
        Types.UserDetails memory buyerDetails,
        uint256 currentTime
    ) internal productExists(barcodeId) {
        Types.Product memory prod = product[barcodeId];
        Types.UserHistory memory history = Types.UserHistory({
            id_: buyerDetails.id_,
            date: currentTime
        });

        if (buyerDetails.role == Types.UserRole.Supplier) {
            productHistory[barcodeId].supplier = history;
        } else if (buyerDetails.role == Types.UserRole.Vendor) {
            productHistory[barcodeId].vendor = history;
        } else if (buyerDetails.role == Types.UserRole.Customer) {
            productHistory[barcodeId].customers.push(history);
        } else {
            revert("Invalid role for transfer");
        }

        transferOwnership(msg.sender, buyer, barcodeId);

        emit ProductOwnershipTransfer(
            prod.name,
            prod.manufacturerName,
            prod.scientificName,
            prod.barcodeId,
            buyerDetails.name,
            buyerDetails.email
        );
    }

    // Moves product from seller to buyer
    function transferOwnership(
        address seller,
        address buyer,
        string memory productId
    ) internal {
        userLinkedProducts[buyer].push(productId);

        string[] storage sellerProducts = userLinkedProducts[seller];
        uint256 indexToRemove = sellerProducts.length;

        for (uint256 i = 0; i < sellerProducts.length; i++) {
            if (compareStrings(sellerProducts[i], productId)) {
                indexToRemove = i;
                break;
            }
        }

        require(indexToRemove < sellerProducts.length, "Product not found");

        if (sellerProducts.length == 1) {
            delete userLinkedProducts[seller];
        } else {
            sellerProducts[indexToRemove] = sellerProducts[
                sellerProducts.length - 1
            ];
            sellerProducts.pop();
        }
    }

    // Utility string comparison
    function compareStrings(
        string memory a,
        string memory b
    ) internal pure returns (bool) {
        return keccak256(bytes(a)) == keccak256(bytes(b));
    }

    // Modifiers
    modifier productExists(string memory id) {
        require(
            !compareStrings(product[id].barcodeId, ""),
            "Product does not exist"
        );
        _;
    }

    modifier productNotExists(string memory id) {
        require(
            compareStrings(product[id].barcodeId, ""),
            "Product already exists"
        );
        _;
    }
}
