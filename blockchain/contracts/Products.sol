// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.28;

import "./Types.sol";

/**
 * @title Products
 * @dev Manages product lifecycle: creation, transfer, delivery, and verification
 */
contract Products {
    using Types for Types.Product;
    using Types for Types.ProductStatus;

    // Mapping of product ID to product data
    mapping(bytes32 => Types.Product) internal products;

    // Events
    event ProductCreated(bytes32 indexed id_, string name);
    event ProductDelivered(bytes32 indexed id_, address indexed to);
    event ProductVerified(bytes32 indexed id_);

    /// @notice Adds a new product to the supply chain
    function add(Types.Product memory product_) internal {
        require(product_.id_ != bytes32(0), "Invalid product ID");
        require(!exists(product_.id_), "Product already exists");

        products[product_.id_] = product_;
        emit ProductCreated(product_.id_, product_.name);
    }

    /// @notice Transfers product ownership and sets status to InTransit
    function transfer(bytes32 id_, address to_) internal {
        require(id_ != bytes32(0), "Empty product ID");
        require(to_ != address(0), "Invalid recipient");
        require(exists(id_), "Product does not exist");

        Types.Product storage product = products[id_];
        product.to_ = to_;
        product.status = Types.ProductStatus.InTransit;
    }

    /// @notice Marks product as delivered and updates current owner
    function deliver(bytes32 id_, address by_) internal {
        require(id_ != bytes32(0), "Empty product ID");
        require(by_ != address(0), "Invalid sender");
        require(exists(id_), "Product does not exist");

        Types.Product storage product = products[id_];
        product.from_ = by_;
        product.owner = product.to_;
        product.status = Types.ProductStatus.Delivered;

        emit ProductDelivered(id_, product.to_);
    }

    /// @notice Verifies authenticity of a delivered product
    function verify(bytes32 id_, address user) internal {
        require(id_ != bytes32(0), "Empty product ID");
        require(user != address(0), "Invalid user");
        require(exists(id_), "Product does not exist");

        Types.Product storage product = products[id_];
        require(
            product.status == Types.ProductStatus.Delivered,
            "Product not delivered"
        );
        require(product.owner == user, "Only owner can verify");

        product.status = Types.ProductStatus.Verified;
        emit ProductVerified(id_);
    }

    /// @notice Retrieves a product's data
    function get(bytes32 id_) internal view returns (Types.Product memory) {
        require(id_ != bytes32(0), "Empty product ID");
        require(exists(id_), "Product does not exist");

        return products[id_];
    }

    /// @notice Checks if a product exists
    function exists(bytes32 id_) internal view returns (bool) {
        return products[id_].id_ != bytes32(0);
    }
}
